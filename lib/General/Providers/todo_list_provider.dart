import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'internal_app_providers.dart';

class TodoListProvider with ChangeNotifier {
  List<Map<String, dynamic>> _todoList = [];
  List<Map<String, dynamic>> get todoList => _todoList;

  Map<String, dynamic> _audioScript = {};
  Map<String, dynamic> get audioScript => _audioScript;

  // Future<void> loadFromStorage() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   _audioScript = prefs.getString('audioScript') ?? '';
  //   final todoListString = prefs.getString('todoList');
  //   if (todoListString != null) {
  //     final decodedList = jsonDecode(todoListString) as List;
  //     _todoList = decodedList.map((item) => item as Map<String, dynamic>).toList();
  //   }
  //   notifyListeners();
  // }

  // -----------------------------------------------------------------------
  // Save to Storage
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioScript', jsonEncode(_audioScript));
    await prefs.setString('todoList', jsonEncode(_todoList));
  }

  // -----------------------------------------------------------------------
  // Helper function to create a WAV header
  Uint8List _createWavHeader(int dataLength) {
    final header = ByteData(44);
    const sampleRate = 16000;
    const numChannels = 1;
    const bitsPerSample = 16;
    const byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);

    // RIFF chunk
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, dataLength + 36, Endian.little);
    header.setUint8(8, 0x57); // 'W'
    header.setUint8(9, 0x41); // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'

    // fmt sub-chunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Sub-chunk1Size for PCM
    header.setUint16(20, 1, Endian.little); // AudioFormat 1 for PCM
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, numChannels * (bitsPerSample ~/ 8), Endian.little); // BlockAlign
    header.setUint16(34, bitsPerSample, Endian.little);

    // data sub-chunk
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, dataLength, Endian.little);

    return header.buffer.asUint8List();
  }

  // -----------------------------------------------------------------------
  // Process Audio
  Future<void> processAudio(
    Uint8List audioBytes, InternalStatusProvider internalStatusProvider,
  ) async {
    final header = _createWavHeader(audioBytes.length);
    final wavData = Uint8List.fromList([...header, ...audioBytes]);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://n8n.seevinckserver.com/webhook/6de75ee4-97ad-4462-a143-20f0b3200241',
      ),
    );
    request.headers.addAll({'Accept': 'application/json'});

    request.files.add(
      http.MultipartFile.fromBytes('audio', wavData, filename: 'audio.wav'),
    );

    request.fields['recordingUID'] = internalStatusProvider.recordingSessionUID ?? '';

    var response = await request.send();

    if (response.statusCode == 200) {
      final respBytes = await response.stream.toBytes();
      final responseBody = utf8.decode(respBytes, allowMalformed: true).trim();

      if (responseBody.isEmpty) {
        throw Exception('Empty response body from processing service');
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(responseBody);
      } catch (e) {
        throw Exception(
          'Failed to decode JSON response: $e — body: $responseBody',
        );
      }

      if (decoded is Map<String, dynamic>) {
        String audioScript = '';
        if (decoded.containsKey('audioTranscript') &&
            decoded['audioTranscript'] is String) {

          audioScript += '${decoded['audioTranscript']}';

          _audioScript['audioTranscript'] = audioScript;
          _audioScript['recordingUID'] = internalStatusProvider.recordingSessionUID ?? '';
        }

        if (decoded.containsKey('todoItems') && decoded['todoItems'] is List) {
          final items = decoded['todoItems'] as List;
          for (var item in items) {
            if (item is Map<String, dynamic>) {
              _todoList.add(item);
            }
          }
        }
        await _saveToStorage();
        notifyListeners();
      } else {
        throw Exception(
          'Unexpected response shape from processing service: $decoded',
        );
      }
    } else {
      final respBytes = await response.stream.toBytes();
      final responseBody = utf8.decode(respBytes, allowMalformed: true).trim();
      throw Exception(
        'Failed to process audio: HTTP ${response.statusCode} — body: $responseBody',
      );
    }
  }
}

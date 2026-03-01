import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'internal_app_providers.dart';

class TodoListProvider with ChangeNotifier {
  List<Map<String, dynamic>> _todoList = [];
  List<Map<String, dynamic>> get todoList => _todoList;

  List<Map<String, dynamic>> _audioScripts = [];
  List<Map<String, dynamic>> get audioScripts => _audioScripts;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  TodoListProvider() {
    loadFromStorage();
  }

  //--------------------------------------------------------------
  // Load from storage function
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      final decodedList = jsonDecode(todoListString) as List;
      _todoList = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    final audioScriptsString = prefs.getString('audioScripts');
    if (audioScriptsString != null) {
      final decodedScripts = jsonDecode(audioScriptsString) as List;
      _audioScripts = decodedScripts.map((item) => item as Map<String, dynamic>).toList();
    }
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Save to storage function
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioScripts', jsonEncode(_audioScripts));
    await prefs.setString('todoList', jsonEncode(_todoList));
  }

  //--------------------------------------------------------------
  // Create WAV header function
  Uint8List _createWavHeader(int dataLength) {
    final header = ByteData(44);
    const sampleRate = 16000;
    const numChannels = 1;
    const bitsPerSample = 16;
    const byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);

    header.setUint8(0, 0x52);
    header.setUint8(1, 0x49);
    header.setUint8(2, 0x46);
    header.setUint8(3, 0x46);
    header.setUint32(4, dataLength + 36, Endian.little);
    header.setUint8(8, 0x57);
    header.setUint8(9, 0x41);
    header.setUint8(10, 0x56);
    header.setUint8(11, 0x45);
    header.setUint8(12, 0x66);
    header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74);
    header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, numChannels * (bitsPerSample ~/ 8), Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    header.setUint8(36, 0x64);
    header.setUint8(37, 0x61);
    header.setUint8(38, 0x74);
    header.setUint8(39, 0x61);
    header.setUint32(40, dataLength, Endian.little);

    return header.buffer.asUint8List();
  }

  //--------------------------------------------------------------
  // Process audio function
  Future<void> processAudio(String userID, Uint8List audioBytes, InternalStatusProvider internalStatusProvider) async {
    final header = _createWavHeader(audioBytes.length);
    final wavData = Uint8List.fromList([...header, ...audioBytes]);
    final recordingUID = internalStatusProvider.recordingSessionUID ?? '';

    _isProcessing = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://n8n.seevinckserver.com/webhook/6de75ee4-97ad-4462-a143-20f0b3200241'),
      );
      request.files.add(http.MultipartFile.fromBytes('audio', wavData, filename: 'audio.wav'));
      request.fields['recordingUID'] = recordingUID;
      request.fields['userID'] = userID;

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);

        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('audioTranscript') && decoded['audioTranscript'] is String) {
            final newTranscript = decoded['audioTranscript'] as String;
            final index = _audioScripts.indexWhere((script) => script['recordingUID'] == recordingUID);

            if (index != -1) {
              _audioScripts[index]['audioTranscript'] = (_audioScripts[index]['audioTranscript'] ?? '') + newTranscript;
            } else {
              _audioScripts.add({
                'recordingUID': recordingUID,
                'audioTranscript': newTranscript,
              });
            }
          }

          if (decoded.containsKey('todoItems') && decoded['todoItems'] is List) {
            final items = decoded['todoItems'] as List;
            for (var item in items) {
              if (item is Map<String, dynamic>) {
                final newItem = Map<String, dynamic>.from(item);
                newItem['recordingUID'] = recordingUID;
                _todoList.add(newItem);
              }
            }
          }
          await _saveToStorage();
        } else {
          throw Exception('Unexpected response shape from processing service: $decoded');
        }
      } else {
        throw Exception('Failed to process audio: HTTP ${response.statusCode} — body: $responseBody');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  //--------------------------------------------------------------
  // Delete to do item function
  Future<void> deleteTodoItem(String todoUID) async {
    final index = _todoList.indexWhere((item) => item['todoUID'] == todoUID);
    if (index != -1) {
      _todoList.removeAt(index);
      await _saveToStorage();
      notifyListeners();
    }
  }

  //--------------------------------------------------------------
  // Delete To-Dos and transcript for a recording UID
  Future<void> _deleteToDosAndTranscript(String recordingUID) async {
    _todoList = _todoList.where((item) => item['recordingUID'] != recordingUID).toList();
    _audioScripts = _audioScripts.where((script) => script['recordingUID'] != recordingUID).toList();
    await _saveToStorage();
    notifyListeners();
  }

  //--------------------------------------------------------------
  // Replace to do item function
  Future<void> replaceTodoItem(String todoUID, Map<String, dynamic> newItem) async {
    final index = _todoList.indexWhere((item) => item['todoUID'] == todoUID);
    if (index != -1) {
      final sanitizedItem = Map<String, dynamic>.from(newItem);
      if (sanitizedItem['deadline'] is DateTime) {
        sanitizedItem['deadline'] = (sanitizedItem['deadline'] as DateTime).toIso8601String();
      }

      _todoList[index] = sanitizedItem;
      await _saveToStorage();
      notifyListeners();
    }
  }

  //--------------------------------------------------------------
  // Process to do items function
  Future<void> processTodoItems(String recordingUID, String authToken, String transcript, List<Map<String, dynamic>> todoItems) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://n8n.seevinckserver.com/webhook/76677254-d36f-4852-946b-db7a80d27af5'),
      );
      request.fields['transcript'] = transcript;
      request.fields['todoItems'] = jsonEncode(todoItems);
      request.headers['authToken'] = authToken;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('processTodoItems Response Status: ${response.statusCode}');
      debugPrint('processTodoItems Response Body: $responseBody');

      if (response.statusCode == 200) {
        _deleteToDosAndTranscript(recordingUID);
      } else {
        throw Exception('Failed to process todo items: HTTP ${response.statusCode} — body: $responseBody');
      }
    } catch (e) {
      debugPrint('Error in processTodoItems: $e');
      rethrow;
    }
  }
}

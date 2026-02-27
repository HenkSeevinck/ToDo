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

  Map<String, dynamic> _currentAudioScript = {};
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // --- NEW: Add a constructor to load data on initialization ---
  TodoListProvider() {
    loadFromStorage();
  }

  // --- NEW: Create the function to load data from SharedPreferences ---
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Load the todoList
    final todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      final decodedList = jsonDecode(todoListString) as List;
      // Ensure the list is of the correct type
      _todoList = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    // Load the audioScripts
    final audioScriptsString = prefs.getString('audioScripts');
    if (audioScriptsString != null) {
      final decodedScripts = jsonDecode(audioScriptsString) as List;
      _audioScripts = decodedScripts.map((item) => item as Map<String, dynamic>).toList();
    }

    // Notify any widgets that are listening that the initial data has loaded.
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Save to Storage
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Your existing logic for updating the audio scripts list is correct.
    // It finds and updates an existing script or adds a new one.
    final currentUID = _currentAudioScript['recordingUID'];
    if (currentUID != null && currentUID.isNotEmpty) {
      final index = _audioScripts.indexWhere(
            (script) => script['recordingUID'] == currentUID,
      );

      if (index != -1) {
        _audioScripts[index] = _currentAudioScript;
      } else {
        _audioScripts.add(_currentAudioScript);
      }
    }

    // Your existing logic for saving the lists is also correct.
    // Because we now load the full list first, this will save the
    // accumulated data correctly.
    await prefs.setString(
      'audioScripts',
      jsonEncode(_audioScripts),
    );
    await prefs.setString('todoList', jsonEncode(_todoList));
  }

  // ... (The rest of your code, including _createWavHeader, clear functions, and processAudio, remains exactly the same) ...
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
    header.setUint16(
      32,
      numChannels * (bitsPerSample ~/ 8),
      Endian.little,
    ); // BlockAlign
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
  Future<void> processAudio(Uint8List audioBytes, InternalStatusProvider internalStatusProvider) async {
    final header = _createWavHeader(audioBytes.length);
    final wavData = Uint8List.fromList([...header, ...audioBytes]);

    _isProcessing = true;
    notifyListeners(); // Keep this one to show the spinner immediately.

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://n8n.seevinckserver.com/webhook/6de75ee4-97ad-4462-a143-20f0b3200241',
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes('audio', wavData, filename: 'audio.wav'),
      );
      request.fields['recordingUID'] =
          internalStatusProvider.recordingSessionUID ?? '';

      var response = await request.send();

      // --- FIX: Read the response body from the stream ---
      final responseBody = await response.stream.bytesToString();
      // --- END FIX ---

      if (response.statusCode == 200) {
        // Now 'responseBody' is defined and can be used.
        final decoded = jsonDecode(responseBody);

        if (decoded is Map<String, dynamic>) {
          // Update all your internal data.
          if (decoded.containsKey('audioTranscript') &&
              decoded['audioTranscript'] is String) {
            _currentAudioScript = {};
            _currentAudioScript['audioTranscript'] = decoded['audioTranscript'];
            _currentAudioScript['recordingUID'] =
                internalStatusProvider.recordingSessionUID ?? '';
          }

          if (decoded.containsKey('todoItems') && decoded['todoItems'] is List) {
            final items = decoded['todoItems'] as List;
            for (var item in items) {
              if (item is Map<String, dynamic>) {
                _todoList.add(item);
              }
            }
          }
          // Save to storage. This function should NOT call notifyListeners.
          await _saveToStorage();
        } else {
          throw Exception(
            'Unexpected response shape from processing service: $decoded',
          );
        }
      } else {
        // 'responseBody' is also available here for better error logging.
        throw Exception(
          'Failed to process audio: HTTP ${response.statusCode} — body: $responseBody',
        );
      }
    } catch (e) {
      // Re-throw the exception so the UI can catch it.
      rethrow;
    } finally {
      // Set final state and notify exactly ONCE.
      _isProcessing = false;
      // This single call tells the UI to both stop the spinner AND show the new data.
      notifyListeners();
    }
  }
}

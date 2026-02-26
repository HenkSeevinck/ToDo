import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  bool _isRecording = false;

  final _audioBuffer = <Uint8List>[];
  Timer? _recordingTimer;

  // Assuming 16-bit PCM, 16kHz sample rate, 1 channel
  static const int _sampleRate = 16000;
  static const int _bytesPerSample = 2;
  static const int _numChannels = 1;
  static const int _bytesPerSecond = _sampleRate * _bytesPerSample * _numChannels;

  // 2 minutes of audio data
  static const int _blockDurationSeconds = 120;
  // 15 seconds overlap
  static const int _overlapDurationSeconds = 15;

  // Trigger processing every 105 seconds (120 - 15)
  static const int _timerDurationSeconds =
      _blockDurationSeconds - _overlapDurationSeconds;

  //----------------------------------------------------------------------
  // Combine byte lists
  Uint8List _combineByteLists(List<Uint8List> lists) {
    final totalLength =
    lists.fold<int>(0, (prev, element) => prev + element.length);
    final combined = Uint8List(totalLength);
    var offset = 0;
    for (final list in lists) {
      combined.setAll(offset, list);
      offset += list.length;
    }
    return combined;
  }

  //----------------------------------------------------------------------
  // Toggle recording
  void toggleRecording({required Function(Uint8List) onAudioBlockReady}) {
    _isRecording = !_isRecording;
    if (_isRecording) {
      _startRecording(onAudioBlockReady);
    } else {
      _stopRecording(onAudioBlockReady);
    }
  }

  //----------------------------------------------------------------------
  // Start recording and set up the timer
  Future<void> _startRecording(Function(Uint8List) onAudioBlockReady) async {
    if (await _audioRecorder.hasPermission()) {
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: _numChannels,
      );

      final stream = await _audioRecorder.startStream(config);
      print("Recording started.");

      _audioStreamSubscription = stream.listen((data) {
        _audioBuffer.add(data);
      });

      _recordingTimer =
          Timer.periodic(const Duration(seconds: _timerDurationSeconds), (_) {
        _processAudioBlock(onAudioBlockReady);
      });
    }
  }

  //----------------------------------------------------------------------
  // Stop recording and clean up
  void _stopRecording(Function(Uint8List) onAudioBlockReady) {
    _recordingTimer?.cancel();
    _audioStreamSubscription?.cancel();
    _audioRecorder.stop();
    _processAudioBlock(onAudioBlockReady); // Process the final block
    _audioBuffer.clear();
    print("Recording stopped.");
  }

  //----------------------------------------------------------------------
  // Process the audio block
  void _processAudioBlock(Function(Uint8List) onAudioBlockReady) {
    if (_audioBuffer.isEmpty) {
      return;
    }

    final fullBlock = _combineByteLists(_audioBuffer);
    print("--- Recording block finished ---");
    onAudioBlockReady(fullBlock);

    // Calculate overlap bytes
    final overlapBytes = _overlapDurationSeconds * _bytesPerSecond;
    int bytesToKeep = overlapBytes;
    int startIndex = fullBlock.length - bytesToKeep;

    if (startIndex < 0) {
      startIndex = 0;
    }

    final overlapData = fullBlock.sublist(startIndex);
    _audioBuffer.clear();
    _audioBuffer.add(overlapData);
  }
}

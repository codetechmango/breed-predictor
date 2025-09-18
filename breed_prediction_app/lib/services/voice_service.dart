import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final SpeechToText _speechToText = SpeechToText();
  static bool _speechEnabled = false;
  static String _wordsSpoken = "";
  static double _confidenceLevel = 0;

  // Initialize speech recognition
  static Future<bool> initialize() async {
    try {
      // Request microphone permission
      PermissionStatus permission = await Permission.microphone.request();
      
      if (permission != PermissionStatus.granted) {
        print('Microphone permission denied');
        return false;
      }

      _speechEnabled = await _speechToText.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      
      return _speechEnabled;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  // Start listening for speech
  static Future<void> startListening(Function(String) onResult) async {
    if (!_speechEnabled) {
      bool initialized = await initialize();
      if (!initialized) return;
    }

    await _speechToText.listen(
      onResult: (result) {
        _wordsSpoken = result.recognizedWords;
        _confidenceLevel = result.confidence;
        onResult(_wordsSpoken);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  // Stop listening
  static Future<void> stopListening() async {
    await _speechToText.stop();
  }

  // Check if currently listening
  static bool get isListening => _speechToText.isListening;

  // Get confidence level
  static double get confidenceLevel => _confidenceLevel;

  // Get last recognized words
  static String get lastWords => _wordsSpoken;

  // Check if speech recognition is available
  static bool get isAvailable => _speechEnabled;
}

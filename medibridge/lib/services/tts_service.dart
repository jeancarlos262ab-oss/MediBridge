import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  static TtsService? _instance;
  bool _speaking = false;

  // Current voice config
  double _rate = 0.9;
  double _pitch = 1.0;
  double _volume = 1.0;

  TtsService._() {
    _applyConfig();
    _tts.setCompletionHandler(() => _speaking = false);
  }

  static TtsService get instance => _instance ??= TtsService._();

  bool get isSpeaking => _speaking;

  /// Call this whenever SettingsProvider voice values change.
  Future<void> applySettings({
    required double rate,
    required double pitch,
    required double volume,
  }) async {
    _rate = rate;
    _pitch = pitch;
    _volume = volume;
    await _applyConfig();
  }

  Future<void> _applyConfig() async {
    await _tts.setVolume(_volume);
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
  }

  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    await _applyConfig();
    await _tts.setLanguage(languageCode);
    _speaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _speaking = false;
    await _tts.stop();
  }
}

import 'package:speech_to_text/speech_to_text.dart';
import '../models/models.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  static SpeechService? _instance;

  SpeechService._();
  static SpeechService get instance => _instance ??= SpeechService._();

  bool get isListening => _speech.isListening;
  bool get isAvailable => _initialized;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    return _initialized;
  }

  Future<void> startListening({
    required Language language,
    required Function(String text) onResult,
    required Function(String partial) onPartial,
    required Function() onDone,
  }) async {
    if (!_initialized) await initialize();
    if (!_initialized) return;

    await _speech.listen(
      localeId: language.speechCode,
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          // NOTE: onDone is intentionally NOT called here.
          // The provider controls when to stop via stopListening().
          // Continuous re-listening is handled in ConsultationProvider.
        } else {
          onPartial(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 8),
      partialResults: true,
      cancelOnError: false,
    );
  }

  /// Re-starts listening with the same parameters. Used for continuous mode.
  Future<void> restartListening({
    required Language language,
    required Function(String text) onResult,
    required Function(String partial) onPartial,
    required Function() onDone,
  }) async {
    await _speech.stop();
    await Future.delayed(const Duration(milliseconds: 150));
    await startListening(
      language: language,
      onResult: onResult,
      onPartial: onPartial,
      onDone: onDone,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  Future<List<LocaleName>> getLocales() async {
    if (!_initialized) await initialize();
    return _speech.locales();
  }
}

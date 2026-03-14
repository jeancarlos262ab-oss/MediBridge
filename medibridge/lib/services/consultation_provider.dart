import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../widgets/urgency_banner.dart';
import '../services/ai_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/history_service.dart'; // ← was supabase_history_service.dart

enum ConsultationState { idle, listening, translating, ready }

class ConsultationProvider extends ChangeNotifier {
  // Languages
  Language _doctorLanguage = LanguageList.byCode('en');
  Language _patientLanguage = LanguageList.byCode('es');

  // Session
  final List<ChatMessage> _messages = [];
  ConsultationSummary? _summary;
  ConsultationState _state = ConsultationState.idle;
  SpeakerRole _activeSpeaker = SpeakerRole.doctor;
  String _partialText = '';
  String? _error;
  bool _summaryLoading = false;
  UrgencyLevel _urgencyLevel = UrgencyLevel.none;
  String _urgencyMessage = '';
  final List<String> _detectedSymptoms = [];
  bool _stopRequested = false; // true when user explicitly taps stop

  // Getters
  Language get doctorLanguage => _doctorLanguage;
  Language get patientLanguage => _patientLanguage;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ConsultationSummary? get summary => _summary;
  ConsultationState get state => _state;
  SpeakerRole get activeSpeaker => _activeSpeaker;
  String get partialText => _partialText;
  String? get error => _error;
  bool get summaryLoading => _summaryLoading;
  UrgencyLevel get urgencyLevel => _urgencyLevel;
  String get urgencyMessage => _urgencyMessage;
  List<String> get detectedSymptoms => List.unmodifiable(_detectedSymptoms);

  void dismissUrgency() {
    _urgencyLevel = UrgencyLevel.none;
    _urgencyMessage = '';
    notifyListeners();
  }

  bool get isListening => _state == ConsultationState.listening;
  bool get hasMessages => _messages.isNotEmpty;

  void setDoctorLanguage(Language lang) {
    _doctorLanguage = lang;
    notifyListeners();
  }

  void setPatientLanguage(Language lang) {
    _patientLanguage = lang;
    notifyListeners();
  }

  void setActiveSpeaker(SpeakerRole role) {
    _activeSpeaker = role;
    notifyListeners();
  }

  Future<void> startListening() async {
    _error = null;
    _stopRequested = false;

    final initialized = await SpeechService.instance.initialize();
    if (!initialized) {
      _error = 'Microphone not available. Check permissions.';
      notifyListeners();
      return;
    }

    _state = ConsultationState.listening;
    _partialText = '';
    notifyListeners();

    await _listenContinuous();
  }

  /// Internal continuous loop — keeps restarting until stopListening() is called.
  Future<void> _listenContinuous() async {
    final lang = _activeSpeaker == SpeakerRole.doctor
        ? _doctorLanguage
        : _patientLanguage;

    while (!_stopRequested) {
      _state = ConsultationState.listening;
      _partialText = '';
      notifyListeners();

      bool segmentDone = false;
      String segmentText = '';

      await SpeechService.instance.startListening(
        language: lang,
        onPartial: (partial) {
          if (!_stopRequested) {
            _partialText = partial;
            notifyListeners();
          }
        },
        onResult: (text) async {
          segmentText = text;
          segmentDone = true;
        },
        onDone: () {
          segmentDone = true;
        },
      );

      // Wait until the current segment finishes
      while (!segmentDone && !_stopRequested) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (_stopRequested) break;

      // Process the captured text (translates + speaks)
      if (segmentText.trim().isNotEmpty) {
        await _processTranscription(segmentText);
      }

      // Small gap before restarting the mic
      if (!_stopRequested) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    _state = ConsultationState.idle;
    _partialText = '';
    notifyListeners();
  }

  Future<void> stopListening() async {
    _stopRequested = true;
    await SpeechService.instance.stopListening();
    _state = ConsultationState.idle;
    _partialText = '';
    notifyListeners();
  }

  Future<void> _processTranscription(String text) async {
    _state = ConsultationState.translating;
    _partialText = '';

    final fromLang = _activeSpeaker == SpeakerRole.doctor
        ? _doctorLanguage
        : _patientLanguage;
    final toLang = _activeSpeaker == SpeakerRole.doctor
        ? _patientLanguage
        : _doctorLanguage;

    final message = ChatMessage(
      speaker: _activeSpeaker,
      originalText: text,
      originalLanguage: fromLang.name,
      targetLanguage: toLang.name,
      status: MessageStatus.translating,
    );

    _messages.add(message);
    notifyListeners();

    try {
      final translated = await AiService.instance.translateMedical(
        text: text,
        fromLanguage: fromLang.name,
        toLanguage: toLang.name,
        speaker: _activeSpeaker,
      );

      message.translatedText = translated;
      message.status = MessageStatus.done;
      _state = ConsultationState.ready;
      notifyListeners();

      _detectUrgency(text);
      _extractSymptoms(text);

      await TtsService.instance.speak(
        text: translated,
        languageCode: toLang.speechCode,
      );
    } catch (e) {
      message.status = MessageStatus.error;
      _error = 'Translation failed. Check your API key.';
      _state = ConsultationState.idle;
      notifyListeners();
    }
  }

  Future<void> generateSummary() async {
    if (_messages.isEmpty) return;
    _summaryLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await AiService.instance.generateSummary(
        messages: _messages,
        patientLanguage: _patientLanguage.name,
        doctorLanguage: _doctorLanguage.name,
      );
    } catch (e) {
      _error = 'Could not generate summary.';
    } finally {
      _summaryLoading = false;
      notifyListeners();
    }
  }

  Future<void> _detectUrgency(String text) async {
    try {
      final result = await AiService.instance.detectUrgency(text: text);
      final levelStr = result['level'] as String? ?? 'none';
      final reason = result['reason'] as String? ?? '';
      final level = {
            'low': UrgencyLevel.low,
            'medium': UrgencyLevel.medium,
            'high': UrgencyLevel.high,
            'critical': UrgencyLevel.critical,
          }[levelStr] ??
          UrgencyLevel.none;
      if (level != UrgencyLevel.none) {
        _urgencyLevel = level;
        _urgencyMessage = reason;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _extractSymptoms(String text) async {
    try {
      final newSymptoms = await AiService.instance.extractSymptoms(text: text);
      if (newSymptoms.isNotEmpty) {
        for (final s in newSymptoms) {
          final normalized = s.toLowerCase().trim();
          if (!_detectedSymptoms
              .any((e) => e.toLowerCase().trim() == normalized)) {
            _detectedSymptoms.add(s);
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveSession() async {
    if (_messages.isEmpty) return;
    final record = SessionRecord(
      date: DateTime.now(),
      doctorLanguage: _doctorLanguage.name,
      patientLanguage: _patientLanguage.name,
      messages: List.from(_messages),
      messageCount: _messages.length,
      summaryData: _summary?.toMap(),
    );
    await HistoryService.instance.save(record); // ← updated service
  }

  void clearSession() {
    _saveSession();
    _messages.clear();
    _summary = null;
    _state = ConsultationState.idle;
    _partialText = '';
    _error = null;
    _detectedSymptoms.clear();
    notifyListeners();
  }

  void speakMessage(ChatMessage msg) {
    final lang =
        msg.speaker == SpeakerRole.doctor ? _patientLanguage : _doctorLanguage;
    TtsService.instance.speak(
      text: msg.translatedText,
      languageCode: lang.speechCode,
    );
  }
}
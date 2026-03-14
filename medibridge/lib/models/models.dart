import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum SpeakerRole { doctor, patient }

enum MessageStatus { transcribing, translating, done, error }

class ChatMessage {
  final String id;
  final SpeakerRole speaker;
  final String originalText;
  final String originalLanguage;
  String translatedText;
  final String targetLanguage;
  MessageStatus status;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.speaker,
    required this.originalText,
    required this.originalLanguage,
    this.translatedText = '',
    required this.targetLanguage,
    this.status = MessageStatus.translating,
    DateTime? timestamp,
  })  : id = id ?? _uuid.v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'speaker': speaker.name,
        'originalText': originalText,
        'originalLanguage': originalLanguage,
        'translatedText': translatedText,
        'targetLanguage': targetLanguage,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'],
        speaker: SpeakerRole.values.byName(j['speaker']),
        originalText: j['originalText'],
        originalLanguage: j['originalLanguage'],
        translatedText: j['translatedText'] ?? '',
        targetLanguage: j['targetLanguage'],
        status: MessageStatus.done,
        timestamp: DateTime.parse(j['timestamp']).toLocal(),
      );
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final String translatedInstructions;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.translatedInstructions,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        name: json['name'] ?? '',
        dosage: json['dosage'] ?? '',
        frequency: json['frequency'] ?? '',
        instructions: json['instructions'] ?? '',
        translatedInstructions: json['translatedInstructions'] ?? '',
      );
}

class ConsultationSummary {
  final String chiefComplaint;
  final String diagnosis;
  final List<Medication> medications;
  final List<String> followUpInstructions;
  final String summaryForPatient;
  final DateTime generatedAt;

  ConsultationSummary({
    required this.chiefComplaint,
    required this.diagnosis,
    required this.medications,
    required this.followUpInstructions,
    required this.summaryForPatient,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'chiefComplaint': chiefComplaint,
        'diagnosis': diagnosis,
        'medications': medications
            .map((m) => {
                  'name': m.name,
                  'dosage': m.dosage,
                  'frequency': m.frequency,
                  'instructions': m.instructions,
                  'translatedInstructions': m.translatedInstructions,
                })
            .toList(),
        'followUpInstructions': followUpInstructions,
        'summaryForPatient': summaryForPatient,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory ConsultationSummary.fromMap(Map<String, dynamic> m) =>
      ConsultationSummary(
        chiefComplaint: m['chiefComplaint'] ?? '',
        diagnosis: m['diagnosis'] ?? '',
        medications: (m['medications'] as List? ?? [])
            .map((e) => Medication.fromJson(e as Map<String, dynamic>))
            .toList(),
        followUpInstructions:
            List<String>.from(m['followUpInstructions'] ?? []),
        summaryForPatient: m['summaryForPatient'] ?? '',
        generatedAt: m['generatedAt'] != null
            ? DateTime.parse(m['generatedAt']).toLocal()
            : DateTime.now(),
      );
}

class SessionRecord {
  final String id;
  final DateTime date;
  final String doctorLanguage;
  final String patientLanguage;
  final List<ChatMessage> messages;
  final int messageCount;
  final Map<String, dynamic>? summaryData; // stored as plain map

  SessionRecord({
    String? id,
    required this.date,
    required this.doctorLanguage,
    required this.patientLanguage,
    required this.messages,
    required this.messageCount,
    this.summaryData,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toUtc().toIso8601String(),
        'doctorLanguage': doctorLanguage,
        'patientLanguage': patientLanguage,
        'messages': messages.map((m) => m.toJson()).toList(),
        'messageCount': messageCount,
        if (summaryData != null) 'summaryData': summaryData,
      };

  factory SessionRecord.fromJson(Map<String, dynamic> j) => SessionRecord(
        id: j['id'],
        date: DateTime.parse(j['date']).toLocal(),
        doctorLanguage: j['doctorLanguage'],
        patientLanguage: j['patientLanguage'],
        messages: (j['messages'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList(),
        messageCount: j['messageCount'],
        summaryData: j['summaryData'] as Map<String, dynamic>?,
      );
}

class Language {
  final String code;
  final String name;
  final String flag;
  final String speechCode;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
    required this.speechCode,
  });
}

class LanguageList {
  static const List<Language> supported = [
    Language(code: 'es', name: 'Español', flag: '🇲🇽', speechCode: 'es-MX'),
    Language(code: 'en', name: 'English', flag: '🇺🇸', speechCode: 'en-US'),
    Language(code: 'pt', name: 'Português', flag: '🇧🇷', speechCode: 'pt-BR'),
    Language(code: 'fr', name: 'Français', flag: '🇫🇷', speechCode: 'fr-FR'),
    Language(code: 'de', name: 'Deutsch', flag: '🇩🇪', speechCode: 'de-DE'),
    Language(code: 'zh', name: '中文', flag: '🇨🇳', speechCode: 'zh-CN'),
    Language(code: 'ar', name: 'العربية', flag: '🇸🇦', speechCode: 'ar-SA'),
    Language(code: 'hi', name: 'हिंदी', flag: '🇮🇳', speechCode: 'hi-IN'),
    Language(code: 'ja', name: '日本語', flag: '🇯🇵', speechCode: 'ja-JP'),
    Language(code: 'ko', name: '한국어', flag: '🇰🇷', speechCode: 'ko-KR'),
  ];

  static Language byCode(String code) => supported
      .firstWhere((l) => l.code == code, orElse: () => supported.first);
}

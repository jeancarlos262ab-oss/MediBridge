import '../models/models.dart';
import 'api_client.dart';

class AiService {
  static AiService? _instance;
  AiService._();
  static AiService get instance => _instance ??= AiService._();

  // ── Translate ──────────────────────────────────────────────────────────────
  Future<String> translateMedical({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    required SpeakerRole speaker,
  }) async {
    final res = await ApiClient.instance.post('/ai/translate', {
      'text': text,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
      'speaker': speaker.name, // 'doctor' | 'patient'
    });

    if (!res.isSuccess)
      throw Exception('Translation failed: ${res.errorMessage}');
    return (res.data as Map<String, dynamic>)['translation'] as String;
  }

  // ── Summary ────────────────────────────────────────────────────────────────
  Future<ConsultationSummary> generateSummary({
    required List<ChatMessage> messages,
    required String patientLanguage,
    required String doctorLanguage,
  }) async {
    final res = await ApiClient.instance.post('/ai/summary', {
      'messages': messages
          .map((m) => {
                'speaker': m.speaker.name,
                'originalText': m.originalText,
              })
          .toList(),
      'patientLanguage': patientLanguage,
      'doctorLanguage': doctorLanguage,
    });

    if (!res.isSuccess) throw Exception('Summary failed: ${res.errorMessage}');
    final raw = (res.data as Map<String, dynamic>)['raw'] as String;
    return _parseSummary(raw);
  }

  // ── Urgency ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> detectUrgency({required String text}) async {
    try {
      final res = await ApiClient.instance.post('/ai/urgency', {'text': text});
      if (!res.isSuccess) return {'level': 'none', 'reason': ''};
      return {
        'level':
            (res.data as Map<String, dynamic>)['level'] as String? ?? 'none',
        'reason': (res.data as Map<String, dynamic>)['reason'] as String? ?? '',
      };
    } catch (_) {
      return {'level': 'none', 'reason': ''};
    }
  }

  // ── Symptoms ───────────────────────────────────────────────────────────────
  Future<List<String>> extractSymptoms({required String text}) async {
    try {
      final res = await ApiClient.instance.post('/ai/symptoms', {'text': text});
      if (!res.isSuccess) return [];
      final raw = (res.data as Map<String, dynamic>)['symptoms'];
      if (raw is List) return List<String>.from(raw);
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── Emergency translate ────────────────────────────────────────────────────
  Future<String> translateEmergency({
    required String text,
    required String targetLanguage,
  }) async {
    try {
      final res = await ApiClient.instance.post('/ai/emergency-translate', {
        'text': text,
        'targetLanguage': targetLanguage,
      });
      if (!res.isSuccess) return text;
      return (res.data as Map<String, dynamic>)['translation'] as String? ??
          text;
    } catch (_) {
      return text;
    }
  }

  // ── Parser (mismo que tenía GeminiService) ─────────────────────────────────
  ConsultationSummary _parseSummary(String raw) {
    String extract(String label) {
      final pattern = RegExp('$label:\\s*(.*?)(?=\\n[A-Z_]+:|\\Z)',
          dotAll: true, caseSensitive: false);
      return pattern.firstMatch(raw)?.group(1)?.trim() ?? '';
    }

    final complaint = extract('COMPLAINT');
    final diagnosis = extract('DIAGNOSIS');
    final medsRaw = extract('MEDICATIONS');
    final followRaw = extract('FOLLOWUP');
    final patientSummary = extract('PATIENT_SUMMARY');

    final meds = <Medication>[];
    if (medsRaw.isNotEmpty && medsRaw.toLowerCase() != 'none') {
      for (final line in medsRaw.split('\n')) {
        final parts = line.split(RegExp(r'[–\-]'));
        if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
          meds.add(Medication(
            name: parts[0].trim(),
            dosage: parts.length > 1 ? parts[1].trim() : '',
            frequency: parts.length > 2 ? parts[2].trim() : '',
            instructions: line.trim(),
            translatedInstructions: line.trim(),
          ));
        }
      }
    }

    final followUp = <String>[];
    if (followRaw.isNotEmpty && followRaw.toLowerCase() != 'none') {
      for (final line in followRaw.split('\n')) {
        final clean = line.replaceFirst(RegExp(r'^[-•*\d.]+\s*'), '').trim();
        if (clean.isNotEmpty) followUp.add(clean);
      }
    }

    return ConsultationSummary(
      chiefComplaint: complaint,
      diagnosis: diagnosis,
      medications: meds,
      followUpInstructions: followUp,
      summaryForPatient: patientSummary,
    );
  }
}

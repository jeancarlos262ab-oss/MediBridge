import '../models/models.dart';
import 'api_client.dart';

/// Replaces both the local HistoryService (SharedPreferences) and
/// SupabaseHistoryService. All sessions are stored server-side in PostgreSQL
/// via the Node.js REST API.
class HistoryService {
  static HistoryService? _instance;
  HistoryService._();
  static HistoryService get instance => _instance ??= HistoryService._();

  // ── Load all sessions for the current user ───────────────────────────────
  Future<List<SessionRecord>> loadAll() async {
    final res = await ApiClient.instance.get('/sessions');
    if (!res.isSuccess) {
      throw ApiException('Could not load sessions: ${res.errorMessage}');
    }

    final list = (res.data as List).cast<Map<String, dynamic>>();
    final records = list.map(SessionRecord.fromJson).toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  // ── Save / upsert one session ────────────────────────────────────────────
  Future<void> save(SessionRecord record) async {
    final res = await ApiClient.instance.post('/sessions', record.toJson());
    if (!res.isSuccess) {
      // Don't throw — saving history should not crash the consultation flow
      print('[HistoryService] save failed: ${res.errorMessage}');
    }
  }

  // ── Delete one session ───────────────────────────────────────────────────
  Future<void> delete(String id) async {
    final res = await ApiClient.instance.delete('/sessions/$id');
    if (!res.isSuccess) {
      throw ApiException('Could not delete session: ${res.errorMessage}');
    }
  }

  // ── Delete all sessions ──────────────────────────────────────────────────
  Future<void> clearAll() async {
    final res = await ApiClient.instance.delete('/sessions');
    if (!res.isSuccess) {
      throw ApiException('Could not clear sessions: ${res.errorMessage}');
    }
  }
}
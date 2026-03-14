import 'api_client.dart';

/// Replacement for the Supabase AuthService.
/// Talks to the Node.js /auth endpoints and stores the JWT via ApiClient.
class AuthService {
  static AuthService? _instance;
  AuthService._();
  static AuthService get instance => _instance ??= AuthService._();

  // In-memory user state (populated after login / register)
  String? _userId;
  String? _userEmail;
  String? _userFullName;
  String? _userAvatarUrl;

  bool get isLoggedIn => ApiClient.instance.hasToken && _userId != null;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userDisplayName => _userFullName;
  String? get userAvatarUrl => _userAvatarUrl;

  /// Call once at app startup to restore a persisted session.
  Future<bool> restoreSession() async {
    await ApiClient.instance.loadToken();
    if (!ApiClient.instance.hasToken) return false;

    try {
      final res = await ApiClient.instance.get('/auth/me');
      if (res.isSuccess) {
        _applyUserData(res.data as Map<String, dynamic>);
        return true;
      } else {
        // Token is invalid / expired — clear it
        await ApiClient.instance.clearToken();
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final res = await ApiClient.instance.post('/auth/register', {
      'email': email,
      'password': password,
      if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
    });

    if (!res.isSuccess) throw AuthException(res.errorMessage);

    final data = res.data as Map<String, dynamic>;
    await ApiClient.instance.saveToken(data['token'] as String);
    _applyUserData(data['user'] as Map<String, dynamic>);
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.instance.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (!res.isSuccess) throw AuthException(res.errorMessage);

    final data = res.data as Map<String, dynamic>;
    await ApiClient.instance.saveToken(data['token'] as String);
    _applyUserData(data['user'] as Map<String, dynamic>);
  }

  // ── Change password ───────────────────────────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await ApiClient.instance.post('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (!res.isSuccess) throw AuthException(res.errorMessage);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await ApiClient.instance.clearToken();
    _userId = null;
    _userEmail = null;
    _userFullName = null;
    _userAvatarUrl = null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _applyUserData(Map<String, dynamic> user) {
    _userId = user['id'] as String?;
    _userEmail = user['email'] as String?;
    _userFullName = user['fullName'] as String?;
    _userAvatarUrl = user['avatarUrl'] as String?;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
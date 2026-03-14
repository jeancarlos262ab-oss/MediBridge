import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Cliente HTTP central para el backend Node.js + MySQL.
/// Guarda el JWT en SharedPreferences y lo adjunta a cada request.
class ApiClient {
  static ApiClient? _instance;
  ApiClient._();
  static ApiClient get instance => _instance ??= ApiClient._();


  static const String baseUrl = 'http://192.168.1.71:3000';


  static const String _tokenKey = 'medibridge_jwt';
  String? _token;

  // ── Token ──────────────────────────────────────────────────────────────────
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get hasToken => _token != null;

  // ── Headers ────────────────────────────────────────────────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── HTTP ───────────────────────────────────────────────────────────────────
  Future<ApiResponse> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return ApiResponse(res.statusCode, _decode(res.body));
    } catch (e) {
      throw ApiException('Error de red: $e');
    }
  }

  Future<ApiResponse> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return ApiResponse(res.statusCode, _decode(res.body));
    } catch (e) {
      throw ApiException('Error de red: $e');
    }
  }

  Future<ApiResponse> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return ApiResponse(res.statusCode, _decode(res.body));
    } catch (e) {
      throw ApiException('Error de red: $e');
    }
  }

  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}

class ApiResponse {
  final int statusCode;
  final dynamic data;
  ApiResponse(this.statusCode, this.data);

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  String get errorMessage {
    if (data is Map && data['error'] != null) return data['error'] as String;
    return 'Error en la solicitud (status $statusCode)';
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
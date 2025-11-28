import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cousify_frontend/services/session_manager.dart';

class AuthService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.20.38:8000';

  static Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'auth-token': '${dotenv.env['AUTH_TOKEN']}',
  };

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _defaultHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final loginData = json.decode(resp.body) as Map<String, dynamic>;

      if (loginData.containsKey('access_token') &&
          loginData.containsKey('user_id')) {
        await SessionManager.saveSession(
          loginData['access_token'],
          loginData['user_id'],
        );
      }

      return loginData;
    }
    throw HttpException('Failed to login: ${resp.statusCode}');
  }

  static Future<void> logout() async {
    await SessionManager.clearSession();
  }

  static Future<void> requestPasswordReset(String email) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/auth/password-reset/request'),
      headers: _defaultHeaders(),
      body: jsonEncode({'email': email}),
    );

    if (resp.statusCode != 200) {
      throw HttpException('No pudimos enviar el código (${resp.statusCode})');
    }
  }

  static Future<void> verifyResetCode(String email, String code) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/auth/password-reset/verify'),
      headers: _defaultHeaders(),
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (resp.statusCode != 200) {
      throw HttpException('Código inválido (${resp.statusCode})');
    }
  }

  static Future<void> resetPasswordWithCode(
    String email,
    String code,
    String newPassword,
  ) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/auth/password-reset/confirm'),
      headers: _defaultHeaders(),
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );

    if (resp.statusCode != 200) {
      throw HttpException('No pudimos actualizar la contraseña (${resp.statusCode})');
    }
  }
}

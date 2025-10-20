import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // URL base desde variable de entorno, con fallback por defecto
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.20.38:8000';

  static Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'auth-token': '${dotenv.env['AUTH_TOKEN']}',
  };

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _defaultHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (resp.statusCode == 200) return json.decode(resp.body) as Map<String, dynamic>;
    throw HttpException('Failed to login: ${resp.statusCode}');
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8080'; // Android Studio localhost ip

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

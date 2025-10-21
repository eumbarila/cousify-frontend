import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cousify_frontend/services/session_manager.dart';

class UserService {
  // URL base desde variable de entorno, con fallback por defecto
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.20.38:8000';

  static Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'auth-token': '${dotenv.env['AUTH_TOKEN']}',
  };

  // GET /user/get/{userId} - obtener perfil del usuario logueado
  static Future<Map<String, dynamic>> getProfile() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final resp = await http.get(
      Uri.parse('$_baseUrl/user/get/$userId'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to load profile: ${resp.statusCode}');
  }

  // PUT /user/edit/{userId} - actualizar perfil del usuario logueado
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final resp = await http.put(
      Uri.parse('$_baseUrl/user/edit/$userId'),
      headers: _defaultHeaders(),
      body: jsonEncode(data),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to update profile: ${resp.statusCode}');
  }

  // POST /auth/logout - cerrar sesión
  static Future<Map<String, dynamic>> logout() async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/auth/logout'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      // También limpiar la sesión local
      await SessionManager.clearSession();
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to logout: ${resp.statusCode}');
  }
}

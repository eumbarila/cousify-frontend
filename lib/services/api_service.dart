import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cousify_frontend/models/course.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // URL base desde variable de entorno, con fallback por defecto
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.20.38:8000';

  static Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'auth-token': '${dotenv.env['AUTH_TOKEN']}',
  };

  static Future<List<Map<String, dynamic>>> getCourses() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/course/'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw HttpException('Failed to get courses: ${resp.statusCode}');
  }

  static Future<bool> updateCourseProgress(
    int courseId,
    double progress,
  ) async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(500)));
    return Random().nextDouble() > 0.1;
  }
}

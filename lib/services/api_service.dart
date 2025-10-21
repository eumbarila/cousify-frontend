import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/services/session_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.20.38:8000';

  static Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'auth-token': '${dotenv.env['AUTH_TOKEN']}',
  };

  static Future<List<Map<String, dynamic>>> getCourses() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final resp = await http.get(
      Uri.parse('$_baseUrl/course/$userId'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw HttpException('Failed to get courses: ${resp.statusCode}');
  }

  static Future<Map<String, dynamic>> getCourseDetail(int courseId) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final resp = await http.get(
      Uri.parse('$_baseUrl/detail/$courseId/$userId'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    throw HttpException('Failed to get course detail: ${resp.statusCode}');
  }

  // PATCH /course/{course_id}/download/{user_id} - toggle download status
  static Future<Map<String, dynamic>> toggleCourseDownload(
    int courseId,
    bool isDownloaded,
  ) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final resp = await http.patch(
      Uri.parse('$_baseUrl/course/$courseId/download/$userId'),
      headers: _defaultHeaders(),
      body: jsonEncode({'is_downloaded': isDownloaded}),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    throw HttpException('Failed to toggle download: ${resp.statusCode}');
  }

  // Filtrar cursos descargados desde getCourses()
  static Future<List<Map<String, dynamic>>> getDownloadedCourses() async {
    final allCourses = await getCourses();
    return allCourses
        .where((course) => course['is_downloaded'] == true)
        .toList();
  }

  static Future<bool> updateCourseProgress(
    int courseId,
    double progress,
  ) async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(500)));
    return Random().nextDouble() > 0.1;
  }
}

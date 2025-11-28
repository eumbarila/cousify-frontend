import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cousify_frontend/services/session_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cousify_frontend/models/WatchListItem.dart';

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
      Uri.parse('$_baseUrl/course/detail/$courseId/$userId'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    throw HttpException('Failed to get course detail: ${resp.statusCode}');
  }

  // PATCH /course/{course_id}/progress/{user_id} - update course progress
  static Future<Map<String, dynamic>> updateCourseProgress(
    int courseId,
    double progress,
  ) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final resp = await http.patch(
      Uri.parse('$_baseUrl/course/$courseId/progress/$userId'),
      headers: _defaultHeaders(),
      body: jsonEncode({'progress': progress}),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    throw HttpException('Failed to update progress: ${resp.statusCode}');
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

  // PUT /{course_id}/certificate/download/{user_id} - make certificate
  static Future<Map<String, dynamic>> downloadCertificate(
      int courseId,
      ) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final resp = await http.put(
      Uri.parse('$_baseUrl/course/$courseId/certificate/download/$userId'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    throw HttpException('Failed to get certificate: ${resp.statusCode}');
  }

  // GET /course/certificate/validate
  static Future<bool> validateCertificate(String certificateCode) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final url = Uri.parse('$_baseUrl/course/certificate/validate')
        .replace(queryParameters: {'certificate_code': certificateCode});

    final resp = await http.get(
      url,
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      final bool isValid = json.decode(resp.body);
      return isValid;
    } else {
      throw HttpException('Failed to validate certificate: ${resp.statusCode}');
    }
  }

  // Filtrar cursos descargados desde getCourses()
  static Future<List<Map<String, dynamic>>> getDownloadedCourses() async {
    final allCourses = await getCourses();
    return allCourses
        .where((course) => course['is_downloaded'] == true)
        .toList();
  }

  // GET /watchlist/get
  static Future<List<WatchlistItem>> getWatchlist() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final url = Uri.parse("$_baseUrl/watchlist/get?user_id=$userId");

    final resp = await http.get(url, headers: _defaultHeaders());

    if (resp.statusCode != 200) {
      throw HttpException('Failed to get watchlist: ${resp.body}');
    }

    final List<dynamic> jsonList = json.decode(resp.body);

    return jsonList.map((e) => WatchlistItem.fromJson(e)).toList();
  }

  // POST /watchlist
  static Future<void> addToWatchlist(String courseId) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final url = Uri.parse("$_baseUrl/watchlist/");

    final body = json.encode({
      "user_id": userId.toString(),
      "course_id": courseId,
    });

    final resp = await http.post(
      url,
      headers: _defaultHeaders(),
      body: body,
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw HttpException("Failed to add to watchlist: ${resp.body}");
    }
  }

  // DELETE /watchlist
  static Future<void> deleteFromWatchlist(int courseId) async {
    final userId = await SessionManager.getUserId();
    if (userId == null) {
      throw HttpException('User not logged in');
    }

    final url = Uri.parse(
      "$_baseUrl/watchlist/?user_id=$userId&course_id=$courseId",
    );

    final resp = await http.delete(url, headers: _defaultHeaders());

    if (resp.statusCode == 204) {
      return;
    }

    if (resp.statusCode == 404) {
      final data = jsonDecode(resp.body);
      throw HttpException(data["detail"] ?? "Error desconocido");
    }

    throw HttpException(
        "Error inesperado: ${resp.statusCode} → ${resp.body}");
  }
}

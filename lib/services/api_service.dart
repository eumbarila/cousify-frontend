import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cousify_frontend/models/course.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080'; // Android Studio localhost ip

  static Map<String, String> _defaultHeaders() => {
    'Content-Type': 'application/json',
    'auth-token': '${dotenv.env['AUTH_TOKEN']}',
  };

  static Future<Course> getCourse(int courseId) async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
    return Course.mock();
  }

  static Future<List<Map<String, dynamic>>> getCourses() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/course/'),
      headers: _defaultHeaders(),
    );

    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data.cast<Map<String, dynamic>>();
    };

    throw HttpException('Failed to get courses: ${resp.statusCode}');
  }

  static Future<List<Course>> getFeaturedCourses() async {
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(800)));
    return [Course.mock()];
  }

  static Future<bool> updateCourseProgress(
    int courseId,
    double progress,
  ) async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(500)));
    return Random().nextDouble() > 0.1;
  }
}

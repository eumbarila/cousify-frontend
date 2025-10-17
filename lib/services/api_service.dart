import 'dart:math';
import 'package:cousify_frontend/models/course.dart';

class ApiService {
  static Future<Course> getCourse(int courseId) async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
    return Course.mock();
  }

  static Future<List<Course>> getCourses() async {
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1200)));
    return [Course.mock()];
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

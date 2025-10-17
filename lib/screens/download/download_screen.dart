import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/screens/download/course_download_item.dart';

class DownloadScreen extends StatelessWidget {
  DownloadScreen({super.key});

  final List<Map<String, String>> _courses = [
    {
      'title': 'Course Title example 1',
      'duration': '2h 3min',
    },
    {
      'title': 'Course Title example 2',
      'duration': '2h 3min',
    },
    {
      'title': 'Course Title example 3',
      'duration': '2h 3min',
    },
    {
      'title': 'Course Title example 4',
      'duration': '2h 3min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Downloads',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final course = _courses[index];
          return CourseDownloadItem(
            title: course['title']!,
            duration: course['duration']!,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Abrir ${course['title']}')),
              );
            },
          );
        },
      ),
    );
  }
}

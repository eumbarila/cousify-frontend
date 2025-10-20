import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/screens/VideoPlayerScreen.dart';

class CourseContentScreen extends StatelessWidget {
  final Course course;

  const CourseContentScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (course.format == "video" && course.videoUrl != null) {
      return VideoPlayerScreen(course: course);
    } else if (course.format == "xapi") {
      return _XapiContentScreen();
    } else {
      return _DefaultContentScreen();
    }
  }

  Widget _XapiContentScreen() {
    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              course.title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          body: Center(
            child: Text(
              'Hola, acá va el contenido xAPI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _DefaultContentScreen() {
    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              course.title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          body: Center(
            child: Text(
              'Formato de curso no soportado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}

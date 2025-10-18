import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/screens/CourseDetailScreen.dart';
import '../services/api_service.dart';
import '../utils/duration_utils.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() async {
    try {
      final data = await ApiService.getCourses();
      final courses = data.map((e) => Course.fromJson(e)).toList();

      setState(() {
        _courses = courses;
        _filteredCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
    }
  }

  void _filterCourses(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCourses = _courses
          .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          TextField(
            onChanged: _filterCourses,
            decoration: InputDecoration(
              hintText: 'Search courses...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text('My Courses', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _buildCourseRow(_filteredCourses, showProgress: true),
          SizedBox(height: 32),
          Text('All Courses', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ..._buildCourseRows(_filteredCourses, 5, showProgress: false),
        ],
      ),
    );
  }

  Widget _buildCourseRow(List<Course> courses, {bool showProgress = false}) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 10),
            child: CourseCard(
              course: courses[index],
              showProgressOverlay: showProgress,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCourseRows(List<Course> courses, int perRow, {bool showProgress = false}) {
    final rows = <Widget>[];
    for (int i = 0; i < courses.length; i += perRow) {
      final rowCourses = courses.sublist(i, (i + perRow > courses.length) ? courses.length : i + perRow);
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildCourseRow(rowCourses, showProgress: showProgress),
        ),
      );
    }
    return rows;
  }

}

class CourseCard extends StatelessWidget {
  final Course course;
  final bool showProgressOverlay;

  const CourseCard({
    required this.course,
    this.showProgressOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    course.titleImage != null
                        ? Image.network(
                      course.titleImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      },
                    )
                        : _placeholderImage(),

                    if (showProgressOverlay && course.progress > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: course.progress / 100,
                          child: Container(
                            color: AppColors.primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Text(
                          course.description,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        course.duration,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Spacer(),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < course.rating.floor() ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.play_circle_outline, size: 50, color: AppColors.primaryColor),
      ),
    );
  }
}


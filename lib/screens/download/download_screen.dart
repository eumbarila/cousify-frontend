import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/services/api_service.dart';
import 'package:cousify_frontend/screens/CourseDetailScreen.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  List<Course> _downloadedCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedCourses();
  }

  void _loadDownloadedCourses() async {
    try {
      final data = await ApiService.getCourses();
      final courses = data.map((e) => Course.fromJson(e)).toList();
      final downloaded = courses.where((c) => c.isDownloaded).toList();

      setState(() {
        _downloadedCourses = downloaded;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading downloaded courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _downloadedCourses.isEmpty
              ? Center(
                  child: Text(
                    'No downloaded courses yet.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _downloadedCourses.length,
                  itemBuilder: (context, index) {
                    final course = _downloadedCourses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CourseCard(
                        course: course,
                        showProgressOverlay: true,
                      ),
                    );
                  },
                ),
    );
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
        height: 120,
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
        child: Row(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
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
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 4,
                          width: double.infinity,
                          child: LinearProgressIndicator(
                            value: course.progress / 100,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      course.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
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
                    ),
                  ],
                ),
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
        child: Icon(Icons.play_circle_outline, size: 40, color: AppColors.primaryColor),
      ),
    );
  }
}

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
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.getDownloadedCourses();
      final courses = data.map((e) => Course.fromJson(e)).toList();

      setState(() {
        _downloadedCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading downloaded courses: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading downloads: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        title: const Text('Downloads', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDownloadedCourses();
        },
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _downloadedCourses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No downloaded courses yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Download courses to access them offline',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
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
                      onDownloadChanged: () =>
                          _loadDownloadedCourses(), // Refresh when download status changes
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final bool showProgressOverlay;
  final VoidCallback? onDownloadChanged;

  const CourseCard({
    required this.course,
    this.showProgressOverlay = false,
    this.onDownloadChanged,
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
        height: 140, // Aumentado de 120 a 140 para más espacio
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
              width: 100, // Reducido de 120 a 100 para dar más espacio al texto
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
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
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título del curso
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 14, // Reducido de 16 a 14
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 3, // Aumentado de 2 a 3 líneas
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Descripción
                    Text(
                      course.description,
                      style: TextStyle(
                        fontSize: 11, // Reducido de 12 a 11
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Barra de progreso
                    if (course.progress > 0) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress: ${course.progress.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: course.progress / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                            minHeight: 3,
                          ),
                        ],
                      ),
                    ],

                    // Fila inferior con duración y rating
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            course.duration,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < course.rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 12, // Reducido de 14 a 12
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
        child: Icon(
          Icons.play_circle_outline,
          size: 40,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

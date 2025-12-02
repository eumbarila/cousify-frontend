import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/services/local_database.dart';
import 'package:cousify_frontend/services/sync_service.dart';
import 'package:cousify_frontend/services/download_manager.dart';
import 'package:cousify_frontend/screens/CourseDetailScreen.dart';
import 'package:cousify_frontend/utils/debug_downloads.dart';

import '../LoginScreen.dart';

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
      // DEBUG: Mostrar lo que hay en SQLite
      await debugDownloads();

      // Cargar cursos descargados desde la base de datos LOCAL
      final localCourses = await LocalDatabase.getAllDownloadedCourses();

      print('📱 Found ${localCourses.length} courses in local database');

      // Convertir a objetos Course
      final courses = localCourses.map((courseData) {
        return Course(
          id: courseData['course_id'] as int,
          title: courseData['title'] as String,
          description: courseData['description'] as String? ?? '',
          duration: 'Offline',
          format: 'video',
          courseType: 'Downloaded',
          learningGoals: [],
          rating: 0,
          isDownloaded: true,
          progress: (courseData['progress'] as num?)?.toDouble() ?? 0,
          titleImage: courseData['thumbnail_url'] as String?,
          tags: [],
          requiresCertificate: false,
          downloadUrl: courseData['video_url'] as String?,
        );
      }).toList();

      setState(() {
        _downloadedCourses = courses;
        _isLoading = false;
      });

      // Intentar sincronizar en segundo plano
      SyncService.syncProgress();
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

  Widget _buildDownloadingCard(DownloadProgress downloadProgress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.downloading,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Downloading...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      downloadProgress.courseTitle.length > 40
                          ? '${downloadProgress.courseTitle.substring(0, 37)}...'
                          : downloadProgress.courseTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${downloadProgress.progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: downloadProgress.progress / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: const Text('Downloads', style: TextStyle(color: Colors.black87)),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _loadDownloadedCourses();
          },
          child: Column(
            children: [
              // Stream de descargas activas
              StreamBuilder<DownloadProgress>(
                stream: DownloadManager().downloadProgressStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final downloadProgress = snapshot.data!;

                  // Solo mostrar si está descargando
                  if (!downloadProgress.isDownloading) {
                    // Si se completó, recargar la lista
                    if (downloadProgress.isCompleted) {
                      Future.delayed(Duration(seconds: 1), () {
                        _loadDownloadedCourses();
                      });
                    }
                    return const SizedBox.shrink();
                  }

                  return _buildDownloadingCard(downloadProgress);
                },
              ),

              // Lista de cursos descargados
              Expanded(
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
                                  _loadDownloadedCourses(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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

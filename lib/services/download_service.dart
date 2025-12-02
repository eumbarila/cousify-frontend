import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cousify_frontend/services/local_database.dart';

class DownloadService {
  static final Dio _dio = Dio();

  /// Descargar video de un curso
  static Future<String> downloadVideo({
    required String videoUrl,
    required int courseId,
    Function(double)? onProgress,
  }) async {
    try {
      // Obtener directorio de almacenamiento
      final directory = await getApplicationDocumentsDirectory();
      final videosDir = Directory('${directory.path}/coursify_videos');

      // Crear directorio si no existe
      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
      }

      // Nombre del archivo
      final fileName = 'course_${courseId}_video.mp4';
      final filePath = '${videosDir.path}/$fileName';

      // Descargar el archivo
      await _dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = (received / total * 100);
            onProgress(progress);
          }
        },
      );

      return filePath;
    } catch (e) {
      throw Exception('Error downloading video: $e');
    }
  }

  /// Descargar curso completo (video + metadata)
  static Future<void> downloadCourse({
    required int courseId,
    required String title,
    required String videoUrl,
    String? description,
    String? thumbnailUrl,
    Function(double)? onProgress,
  }) async {
    // Verificar si ya está descargado
    final isDownloaded = await LocalDatabase.isCourseDownloaded(courseId);
    if (isDownloaded) {
      throw Exception('Course already downloaded');
    }

    // Descargar video
    final videoPath = await downloadVideo(
      videoUrl: videoUrl,
      courseId: courseId,
      onProgress: onProgress,
    );

    // Guardar en base de datos local
    await LocalDatabase.saveCourse(
      courseId: courseId,
      title: title,
      description: description,
      videoUrl: videoUrl,
      videoPath: videoPath,
      thumbnailUrl: thumbnailUrl,
    );
  }

  /// Eliminar curso descargado
  static Future<void> deleteCourse(int courseId) async {
    // Obtener información del curso
    final course = await LocalDatabase.getCourse(courseId);
    if (course == null) return;

    // Eliminar archivo de video
    final videoPath = course['video_path'] as String?;
    if (videoPath != null) {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Eliminar de base de datos
    await LocalDatabase.deleteCourse(courseId);
  }

  /// Obtener tamaño de archivo en MB
  static Future<double> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final bytes = await file.length();
      return bytes / (1024 * 1024); // Convertir a MB
    }
    return 0;
  }

  /// Verificar si hay espacio suficiente (simplificado)
  static Future<bool> hasEnoughSpace() async {
    // Esta es una versión simplificada
    // En producción deberías verificar el espacio real disponible
    return true;
  }
}

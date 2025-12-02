import 'package:cousify_frontend/services/local_database.dart';

/// Función de debug para ver los cursos descargados
Future<void> debugDownloads() async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📦 DEBUG: Cursos descargados en SQLite');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  try {
    final courses = await LocalDatabase.getAllDownloadedCourses();

    if (courses.isEmpty) {
      print('❌ No hay cursos descargados');
    } else {
      print('✅ ${courses.length} curso(s) descargado(s):');
      for (var course in courses) {
        print('');
        print('  ID: ${course['course_id']}');
        print('  Título: ${course['title']}');
        print('  Video path: ${course['video_path']}');
        print('  Progreso: ${course['progress']}%');
        print('  Sincronizado: ${course['is_synced'] == 1 ? 'Sí' : 'No'}');
        print('  Descargado: ${course['downloaded_at']}');
      }
    }
  } catch (e) {
    print('❌ Error al leer la base de datos: $e');
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cousify_frontend/services/local_database.dart';
import 'package:cousify_frontend/services/api_service.dart';

class SyncService {
  /// Verificar si hay conexión a internet
  static Future<bool> hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Sincronizar progreso de cursos offline al backend
  static Future<void> syncProgress() async {
    // Verificar conexión
    final hasConnection = await hasInternet();
    if (!hasConnection) {
      log('No internet connection, skipping sync', name: 'SyncService');
      return;
    }

    // Obtener cursos no sincronizados
    final unsyncedCourses = await LocalDatabase.getUnsyncedCourses();

    if (unsyncedCourses.isEmpty) {
      log('No courses to sync', name: 'SyncService');
      return;
    }

    log('Syncing ${unsyncedCourses.length} courses', name: 'SyncService');

    // Sincronizar cada curso
    for (var course in unsyncedCourses) {
      try {
        final courseId = course['course_id'] as int;
        final progress = course['progress'] as double;

        // Enviar progreso al backend
        await ApiService.updateCourseProgress(courseId, progress);

        // Marcar como sincronizado
        await LocalDatabase.markAsSynced(courseId);

        log('Synced course $courseId with progress $progress%',
            name: 'SyncService');
      } catch (e) {
        log('Error syncing course ${course['course_id']}: $e',
            name: 'SyncService', error: e);
        // Continuar con el siguiente curso aunque falle uno
      }
    }

    log('Sync completed', name: 'SyncService');
  }

  /// Iniciar listener de conectividad para sincronizar automáticamente
  static void startSyncListener() {
    Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      final hasConnection = connectivityResult != ConnectivityResult.none;

      if (hasConnection) {
        log('Internet connection detected, syncing...', name: 'SyncService');
        await syncProgress();
      }
    });
  }

  /// Actualizar progreso (guarda local y sincroniza si hay internet)
  static Future<void> updateProgress(int courseId, double progress) async {
    // Guardar localmente primero
    await LocalDatabase.updateProgress(courseId, progress);
    log('Progress updated locally: $courseId -> $progress%',
        name: 'SyncService');

    // Intentar sincronizar inmediatamente
    final hasConnection = await hasInternet();
    if (hasConnection) {
      try {
        await ApiService.updateCourseProgress(courseId, progress);
        await LocalDatabase.markAsSynced(courseId);
        log('Progress synced immediately: $courseId', name: 'SyncService');
      } catch (e) {
        log('Failed to sync immediately, will retry later: $e',
            name: 'SyncService', error: e);
      }
    } else {
      log('No internet, progress will sync later', name: 'SyncService');
    }
  }
}

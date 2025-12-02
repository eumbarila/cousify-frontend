import 'dart:async';

/// Singleton para gestionar el estado de las descargas en toda la app
class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  // Stream para notificar cambios en el progreso de descarga
  final _downloadProgressController = StreamController<DownloadProgress>.broadcast();
  Stream<DownloadProgress> get downloadProgressStream => _downloadProgressController.stream;

  // Mapa de descargas activas: courseId -> progress
  final Map<int, double> _activeDownloads = {};

  /// Iniciar descarga
  void startDownload(int courseId, String courseTitle) {
    _activeDownloads[courseId] = 0;
    _downloadProgressController.add(
      DownloadProgress(
        courseId: courseId,
        courseTitle: courseTitle,
        progress: 0,
        isDownloading: true,
        isCompleted: false,
      ),
    );
  }

  /// Actualizar progreso
  void updateProgress(int courseId, String courseTitle, double progress) {
    _activeDownloads[courseId] = progress;
    _downloadProgressController.add(
      DownloadProgress(
        courseId: courseId,
        courseTitle: courseTitle,
        progress: progress,
        isDownloading: true,
        isCompleted: progress >= 100,
      ),
    );
  }

  /// Completar descarga
  void completeDownload(int courseId, String courseTitle) {
    _activeDownloads.remove(courseId);
    _downloadProgressController.add(
      DownloadProgress(
        courseId: courseId,
        courseTitle: courseTitle,
        progress: 100,
        isDownloading: false,
        isCompleted: true,
      ),
    );
  }

  /// Error en descarga
  void errorDownload(int courseId, String courseTitle, String error) {
    _activeDownloads.remove(courseId);
    _downloadProgressController.add(
      DownloadProgress(
        courseId: courseId,
        courseTitle: courseTitle,
        progress: 0,
        isDownloading: false,
        isCompleted: false,
        error: error,
      ),
    );
  }

  /// Verificar si un curso se está descargando
  bool isDownloading(int courseId) => _activeDownloads.containsKey(courseId);

  /// Obtener progreso actual
  double? getProgress(int courseId) => _activeDownloads[courseId];

  void dispose() {
    _downloadProgressController.close();
  }
}

class DownloadProgress {
  final int courseId;
  final String courseTitle;
  final double progress;
  final bool isDownloading;
  final bool isCompleted;
  final String? error;

  DownloadProgress({
    required this.courseId,
    required this.courseTitle,
    required this.progress,
    required this.isDownloading,
    required this.isCompleted,
    this.error,
  });
}

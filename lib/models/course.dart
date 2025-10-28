class Course {
  final int id;
  final String title;
  final String description;
  final String duration;
  final String format; // 'video', 'xapi', 'pdf'
  final String courseType; 
  final List<String> learningGoals;
  final double rating;
  final bool isDownloaded;
  final double progress;
  final String? titleImage;
  final List<String>? tags;
  final bool requiresCertificate;
  final String? downloadUrl; // URL de descarga del backend (para video)

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.format,
    required this.courseType,
    required this.learningGoals,
    required this.rating,
    required this.isDownloaded,
    required this.progress,
    this.titleImage,
    this.tags,
    required this.requiresCertificate,
    this.downloadUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      format: json['format'],
      courseType: json['course_type'],
      learningGoals: List<String>.from(json['learning_goals'] ?? []),
      rating: (json['rating'] as num).toDouble(),
      isDownloaded: json['is_downloaded'],
      progress: (json['progress'] as num).toDouble(),
      titleImage: json['thumbnail_url'],
      tags: List<String>.from(json['tags'] ?? []),
      requiresCertificate: json['requires_certificate'],
      downloadUrl: json['download_url'], // URL del backend para el video
    );
  }
}

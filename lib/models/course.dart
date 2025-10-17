class Course {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String format; // 'video', 'xapi', 'pdf'
  final String courseType; 
  final List<String> learningGoals;
  final double rating;
  final bool isDownloaded;
  final double progress;
  final String? titleImage;
  final List<String>? tags;
  final bool requiresCertificate;

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
  });

  factory Course.mock() {
    return Course(
      id: 1,
      title: 'Introduction to Flutter Development',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
      duration: 234,
      format: 'video',
      courseType: 'self_paced',
      learningGoals: [
        'In this course, you will learn the fundamentals of Flutter development, including widgets, state management, and building responsive UIs.',
        'In this course, you will learn the fundamentals of Flutter development, including widgets, state management, and building responsive UIs.',
        'In this course, you will learn the fundamentals of Flutter development, including widgets, state management, and building responsive UIs.',
      ],
      rating: 4.5,
      isDownloaded: false,
      progress: 45,
      titleImage:
          'https://i.pinimg.com/1200x/db/cd/1d/dbcd1dd88f1f3b4a2f391921c82a77e2.jpg',
      tags: ['Flutter', 'Mobile Development', 'Dart'],
      requiresCertificate: true,
    );
  }
}

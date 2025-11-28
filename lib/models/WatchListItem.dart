class WatchlistItem {
  final String id;
  final String courseId;
  final String userId;
  final DateTime createdAt;

  WatchlistItem({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.createdAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json["id"],
      courseId: json["course_id"],
      userId: json["user_id"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
class RecentActivity {
  final String title;
  final String message;
  final String time;

  RecentActivity({
    required this.title,
    required this.message,
    required this.time,
  });

  factory RecentActivity.fromMap(Map<dynamic, dynamic> data) {
    return RecentActivity(
      title: data['title'] ?? 'No Title',
      message: data['message'] ?? 'No Message',
      time: data['time'] ?? '',
    );
  }
}

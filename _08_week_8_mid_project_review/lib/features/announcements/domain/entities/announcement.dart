/// Pure domain entity for an academic announcement.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.publishedAt,
    this.isUrgent = false,
  });

  final int id;
  final String title;
  final String content;
  final String category;
  final DateTime publishedAt;
  final bool isUrgent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          category == other.category &&
          publishedAt == other.publishedAt &&
          isUrgent == other.isUrgent;

  @override
  int get hashCode =>
      Object.hash(id, title, content, category, publishedAt, isUrgent);
}

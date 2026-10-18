/// Domain entity for Academic Announcements.
/// Completely decoupled from JSON or database libraries.
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
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      publishedAt.hashCode ^
      isUrgent.hashCode;
}

import '../../domain/entities/announcement.dart';

/// Data model handling JSON/Map serialization for [Announcement].
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.content,
    required super.category,
    required super.publishedAt,
    super.isUrgent = false,
  });

  factory AnnouncementModel.fromMap(Map<String, Object?> map) {
    return AnnouncementModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? 'Tanpa Judul',
      content: map['content'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      publishedAt:
          DateTime.tryParse(map['published_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isUrgent: (map['is_urgent'] as bool?) ?? false,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'published_at': publishedAt.toIso8601String(),
    'is_urgent': isUrgent,
  };

  Announcement toEntity() => Announcement(
    id: id,
    title: title,
    content: content,
    category: category,
    publishedAt: publishedAt,
    isUrgent: isUrgent,
  );
}

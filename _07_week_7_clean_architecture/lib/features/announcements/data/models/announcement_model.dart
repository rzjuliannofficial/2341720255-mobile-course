import '../../domain/entities/announcement.dart';

/// Data Model for Announcement.
/// Handles conversion between Map/JSON and domain Entity.
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.content,
    required super.category,
    required super.publishedAt,
    super.isUrgent = false,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      publishedAt: DateTime.tryParse(map['published_at'] as String? ?? '') ??
          DateTime.now(),
      isUrgent: map['is_urgent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
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

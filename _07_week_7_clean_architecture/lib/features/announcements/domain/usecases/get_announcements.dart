import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

/// Use case: Fetch academic announcements with optional category filter.
class GetAnnouncements {
  const GetAnnouncements(this._repository);
  final AnnouncementRepository _repository;

  Future<({List<Announcement> announcements, Failure? failure})> call({
    String? category,
  }) {
    return _repository.fetchAnnouncements(category: category);
  }
}

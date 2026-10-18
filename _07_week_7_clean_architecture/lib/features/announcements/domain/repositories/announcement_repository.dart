import '../../../../core/failures.dart';
import '../entities/announcement.dart';

/// Contract interface for Announcement data operations.
abstract class AnnouncementRepository {
  /// Fetches announcements optionally filtered by [category].
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements({String? category});

  /// Fetches a specific announcement by [id].
  Future<({Announcement? announcement, Failure? failure})> getAnnouncementById(
      int id);
}

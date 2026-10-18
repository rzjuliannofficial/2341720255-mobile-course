import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Contract interface for Note data operations required by the domain layer.
abstract class NoteRepository {
  /// Fetches all stored notes ordered by recent updates.
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  /// Adds a new note with [title] and optional [body].
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });

  /// Deletes a note by its [id].
  Future<({bool success, Failure? failure})> deleteNote(int id);
}

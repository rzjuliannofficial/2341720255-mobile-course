import '../entities/note.dart';
import '../entities/notes_query.dart';

/// Pure domain use case that filters and sorts notes without mutating input.
class SearchNotes {
  const SearchNotes();

  /// Applies case-insensitive substring matching, sync filter, and sorting.
  List<Note> call(List<Note> notes, NotesQuery query) {
    final normalizedQuery = query.query.trim().toLowerCase();

    final filtered = notes.where((note) {
      final matchesSync = switch (query.syncFilter) {
        NoteSyncFilter.all => true,
        NoteSyncFilter.dirtyOnly => note.dirty,
        NoteSyncFilter.syncedOnly => !note.dirty,
      };
      if (!matchesSync) return false;

      if (normalizedQuery.isEmpty) return true;
      return note.title.toLowerCase().contains(normalizedQuery) ||
          note.body.toLowerCase().contains(normalizedQuery);
    }).toList();

    switch (query.sortOrder) {
      case NoteSortOrder.newestFirst:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case NoteSortOrder.titleAsc:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }

    return List<Note>.unmodifiable(filtered);
  }
}

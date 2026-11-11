import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/clock.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/notes_query.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';

/// Shared clock provider overridden in deterministic tests.
final appClockProvider = Provider<AppClock>((ref) => const SystemClock());

/// Repository implementation provider backed by local SQLite.
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(
    openDb: openNotesDb,
    clock: ref.watch(appClockProvider),
  );
});

/// Domain use case providers receiving [NoteRepository] abstraction only.
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

final searchNotesProvider = Provider<SearchNotes>((ref) => const SearchNotes());

/// Manages active search query, sync filter, and sort order via Riverpod 3.x.
class NotesQueryNotifier extends Notifier<NotesQuery> {
  @override
  NotesQuery build() => const NotesQuery();

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setSyncFilter(NoteSyncFilter filter) {
    state = state.copyWith(syncFilter: filter);
  }

  void setSortOrder(NoteSortOrder sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  void reset() {
    state = const NotesQuery();
  }
}

final notesQueryProvider = NotifierProvider<NotesQueryNotifier, NotesQuery>(
  NotesQueryNotifier.new,
);

/// ViewModel managing notes persistence state and typed domain failures.
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    return _loadNotes();
  }

  Future<List<Note>> _loadNotes() async {
    final result = await ref.read(getNotesProvider).call();
    if (result.failure != null) {
      throw result.failure!;
    }
    return result.notes;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadNotes);
  }

  Future<({bool success, String? error})> addNote({
    required String title,
    String body = '',
  }) async {
    final result = await ref
        .read(addNoteProvider)
        .call(title: title, body: body);
    if (result.failure != null) {
      return (success: false, error: result.failure!.message);
    }
    await refresh();
    return (success: true, error: null);
  }

  Future<({bool success, String? error})> deleteNote(int id) async {
    final result = await ref.read(deleteNoteProvider).call(id);
    if (result.failure != null) {
      return (success: false, error: result.failure!.message);
    }
    await refresh();
    return (success: true, error: null);
  }
}

final notesNotifierProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

/// Derived filtered and sorted notes list computed from [notesNotifierProvider].
final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesNotifierProvider);
  final query = ref.watch(notesQueryProvider);
  final search = ref.watch(searchNotesProvider);

  return notesAsync.whenData((notes) => search.call(notes, query));
});

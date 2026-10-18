import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';

// DATA LAYER DI: Database opener is injected, easily swapped with a fake in tests
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// DOMAIN LAYER DI: Use cases receive repository abstraction, not concretion
final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

// PRESENTATION LAYER: AsyncNotifier managing UI state & user actions
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final useCase = ref.watch(getNotesProvider);
    final result = await useCase.call();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getNotesProvider).call();
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return result.notes;
    });
  }

  Future<({bool success, String? error})> addNote({
    required String title,
    String body = '',
  }) async {
    final addUseCase = ref.read(addNoteProvider);
    final result = await addUseCase.call(title: title, body: body);

    if (result.failure != null) {
      return (success: false, error: result.failure!.message);
    }

    // Refresh state after successful addition
    await refresh();
    return (success: true, error: null);
  }

  Future<({bool success, String? error})> deleteNote(int id) async {
    final deleteUseCase = ref.read(deleteNoteProvider);
    final result = await deleteUseCase.call(id);

    if (result.failure != null) {
      return (success: false, error: result.failure!.message);
    }

    await refresh();
    return (success: true, error: null);
  }
}

final notesNotifierProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

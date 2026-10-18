import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

/// Use case: Delete a note by id.
class DeleteNote {
  const DeleteNote(this._repository);
  final NoteRepository _repository;

  Future<({bool success, Failure? failure})> call(int id) {
    if (id <= 0) {
      return Future.value((
        success: false,
        failure: const ValidationFailure('ID catatan tidak valid.'),
      ));
    }
    return _repository.deleteNote(id);
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

/// Provider instansiasi CommentRepository yang menggunakan Dio terpusat (dioProvider).
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// State notifier untuk postId yang sedang dipilih
class SelectedPostIdNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void selectPost(int id) => state = id;
}

final selectedPostIdProvider =
    NotifierProvider<SelectedPostIdNotifier, int>(SelectedPostIdNotifier.new);

/// Notifier asinkron untuk mengambil komentar berdasarkan postId.
/// Exception dari repository otomatis menjadi AsyncError (deklaratif).
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    final postId = ref.watch(selectedPostIdProvider);
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  /// Memperbarui atau memuat ulang komentar secara manual
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final postId = ref.read(selectedPostIdProvider);
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider komentar berbasis AsyncNotifierProvider dengan penonaktifan
/// auto-retry Riverpod agar mudah diuji dan responsif menangani error.
final commentListProvider =
    AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
  CommentListNotifier.new,
  retry: (retryCount, error) => null,
);

/// Fungsi penerjemah exception jaringan Dio ke pesan ramah pengguna.
/// Menangani timeout, connection error, status HTTP 404, 500, dan lainnya.
String commentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout (lebih dari 10 detik). Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Komentar tidak ditemukan (404).';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Terjadi gangguan pada server internal (500). Coba beberapa saat lagi.';
        }
        return 'Server merespons dengan kode $statusCode. Silakan coba lagi.';
      case DioExceptionType.cancel:
        return 'Permintaan data dibatalkan.';
      default:
        return 'Terjadi kendala pada jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan sistem: $error';
}

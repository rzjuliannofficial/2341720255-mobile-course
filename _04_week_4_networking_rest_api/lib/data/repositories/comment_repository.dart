import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository layer untuk menangani pemanggilan API comments.
/// Mematuhi Clean Architecture: UI tidak memanggil Dio langsung,
/// melainkan melalui CommentRepository.
class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan postId dengan query parameter `postId`.
  /// Dio client sudah memiliki konfigurasi connectTimeout & receiveTimeout 10 detik,
  /// dan Options di bawah ini memastikan penegasan timeout 10 detik.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_04_week_4_networking_rest_api/data/models/comment.dart';
import 'package:_04_week_4_networking_rest_api/data/comment_providers.dart';

void main() {
  group('Comment Model Tests', () {
    test('fromJson dengan field yang hilang/null menghasilkan default value aman', () {
      // Simulasi JSON response yang tidak lengkap (missing fields)
      final jsonWithMissingFields = <String, dynamic>{
        'id': 10,
        // postId, name, email, dan body sengaja dihilangkan
      };

      final comment = Comment.fromJson(jsonWithMissingFields);

      // Verifikasi bahwa parsing tidak crash dan menghasilkan fallback default yang aman
      expect(comment.id, 10);
      expect(comment.postId, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('fromJson edge-case: tipe data numeric/string tidak terduga', () {
      // Edge-case: backend mengirimkan angka sebagai string atau null eksplisit
      final jsonWithOddTypes = <String, dynamic>{
        'postId': 42.0, // dikirim sebagai double
        'id': null,     // null eksplisit
        'name': null,
        'email': 'valid@example.com',
        'body': null,
      };

      final comment = Comment.fromJson(jsonWithOddTypes);

      expect(comment.postId, 42);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, 'valid@example.com');
      expect(comment.body, '');
    });
  });

  group('commentErrorMessage Tests', () {
    test('memetakan timeout ke pesan ramah pengguna', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = commentErrorMessage(dioError);
      expect(message, contains('timeout'));
    });

    test('memetakan status 404 ke pesan data tidak ditemukan', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 404,
        ),
      );

      final message = commentErrorMessage(dioError);
      expect(message, contains('404'));
      expect(message, contains('tidak ditemukan'));
    });

    test('memetakan status 500 ke pesan server internal error', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 500,
        ),
      );

      final message = commentErrorMessage(dioError);
      expect(message, contains('500'));
      expect(message, contains('gangguan pada server'));
    });
  });
}

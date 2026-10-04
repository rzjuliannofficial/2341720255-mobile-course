import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_04_week_4_networking_rest_api/data/models/post.dart';
import 'package:_04_week_4_networking_rest_api/data/providers.dart';
import 'package:_04_week_4_networking_rest_api/data/repositories/post_repository.dart';

/// Fake/Mock Repository untuk menguji skenario sukses dan gagal tanpa HTTP nyata
class FakePostRepository implements PostRepository {
  FakePostRepository({
    this.shouldThrow = false,
    this.mockPosts = const [],
    this.throwException,
  });

  final bool shouldThrow;
  final List<Post> mockPosts;
  final Exception? throwException;

  @override
  Future<List<Post>> fetchPosts() async {
    if (shouldThrow) {
      throw throwException ??
          DioException(
            requestOptions: RequestOptions(path: '/posts'),
            type: DioExceptionType.connectionError,
          );
    }
    return mockPosts;
  }

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    if (shouldThrow) {
      throw throwException ??
          DioException(
            requestOptions: RequestOptions(path: '/posts'),
            type: DioExceptionType.connectionError,
          );
    }
    return mockPosts;
  }
}

void main() {
  group('Post Model Tests', () {
    test('Post.fromJson parsing normal berhasil', () {
      final json = {
        'userId': 1,
        'id': 101,
        'title': 'Judul Post',
        'body': 'Isi deskripsi post.',
      };

      final post = Post.fromJson(json);

      expect(post.userId, 1);
      expect(post.id, 101);
      expect(post.title, 'Judul Post');
      expect(post.body, 'Isi deskripsi post.');
    });

    test('Post.fromJson aman null dan missing field', () {
      final json = <String, dynamic>{};
      final post = Post.fromJson(json);

      expect(post.userId, 0);
      expect(post.id, 0);
      expect(post.title, '');
      expect(post.body, '');
    });
  });

  group('Post Providers & Testing Helper Tests', () {
    test('readPostsOnce membaca data dari provider dengan FakePostRepository',
        () async {
      final mockData = [
        const Post(
          userId: 1,
          id: 1,
          title: 'Post Pertama',
          body: 'Konten Pertama',
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(mockPosts: mockData),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await readPostsOnce(container);

      expect(result.length, 1);
      expect(result.first.title, 'Post Pertama');
    });

    test('readPostsErrorOnce menangkap DioException dari FakePostRepository',
        () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(
              shouldThrow: true,
              throwException: DioException(
                requestOptions: RequestOptions(path: '/posts'),
                type: DioExceptionType.connectionTimeout,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final error = await readPostsErrorOnce(container);

      expect(error, isA<DioException>());
      final dioError = error as DioException;
      expect(dioError.type, DioExceptionType.connectionTimeout);

      final message = friendlyErrorMessage(dioError);
      expect(message, contains('timeout'));
    });
  });

  group('friendlyErrorMessage Unit Tests', () {
    test('memetakan connectionError dengan benar', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyErrorMessage(err), contains('Tidak dapat terhubung'));
    });

    test('memetakan status 404 badResponse dengan benar', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts'),
          statusCode: 404,
        ),
      );
      expect(friendlyErrorMessage(err), contains('404'));
    });
  });
}

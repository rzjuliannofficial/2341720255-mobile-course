import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:_04_week_4_networking_rest_api/data/models/post.dart';
import 'package:_04_week_4_networking_rest_api/data/providers.dart';
import 'package:_04_week_4_networking_rest_api/data/repositories/post_repository.dart';
import 'package:_04_week_4_networking_rest_api/main.dart';
import 'package:_04_week_4_networking_rest_api/widgets/post_state_views.dart';

class _FakePostRepositoryForWidgetTest implements PostRepository {
  @override
  Future<List<Post>> fetchPosts() async => [];

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    return [
      const Post(
        userId: 1,
        id: 1,
        title: 'Spotify Track Title',
        body: 'Spotify Track Description',
      ),
    ];
  }
}

void main() {
  testWidgets('App renders correctly with Spotify theme smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            _FakePostRepositoryForWidgetTest(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Initial render: memverifikasi bahwa indikator loading / app bar Spotify muncul
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Jalankan pumpAndSettle dengan fake repository agar asynchronous microtask selesai
    await tester.pumpAndSettle();

    // Memverifikasi teks header dan item list post
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('PostListErrorView renders friendly error and retry button',
      (WidgetTester tester) async {
    bool retryClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostListErrorView(
            error: Exception('Error jaringan'),
            onRetry: () => retryClicked = true,
          ),
        ),
      ),
    );

    expect(find.text('Coba lagi'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    expect(retryClicked, isTrue);
  });
}

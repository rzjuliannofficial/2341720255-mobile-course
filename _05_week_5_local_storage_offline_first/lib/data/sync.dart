import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

class Post {
  const Post({
    required this.id,
    required this.title,
    required this.body,
  });

  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
      };
}

/// Sinkronisasi catatan kotor (dirty) ke server simulasi
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulasi upload ke remote server
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

/// Provider penanda simulasi offline untuk testing deterministik
final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setOffline(bool value) => state = value;
}

/// Provider Cache-First untuk data Post API
final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<Post>>(
        CachedPostsNotifier.new);

class CachedPostsNotifier extends AsyncNotifier<List<Post>> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  static final List<Post> _webCachedPosts = [
    const Post(
      id: 1,
      title: 'sunt aut facere repellat provident occaecati excepturi optio',
      body:
          'quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam',
    ),
    const Post(
      id: 2,
      title: 'qui est esse',
      body:
          'est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea dolores neque fugiat blanditiis voluptate porro vel',
    ),
    const Post(
      id: 3,
      title: 'ea molestias quasi exercitationem repellat qui ipsa sit aut',
      body:
          'et iusto sed quo iure voluptatem occaecati omnis eligendi aut ad voluptatem doloribus vel accusantium quis pariatur',
    ),
    const Post(
      id: 4,
      title: 'eum et est occaecati',
      body:
          'ullam et saepe reiciendis voluptatem adipisci sit amet autem assumenda provident rerum culpa quis hic commodi',
    ),
  ];

  @override
  Future<List<Post>> build() async {
    // 1. Baca cache lokal terlebih dahulu (Cache-First Read)
    final cached = await _readCachedPosts();

    // 2. Refresh jaringan di background jika tidak dalam mode forceOffline
    final isOffline = ref.watch(forceOfflineProvider);
    if (!isOffline) {
      _refreshInBackground();
    }

    return cached;
  }

  Future<List<Post>> _readCachedPosts() async {
    if (kIsWeb) {
      return List<Post>.from(_webCachedPosts);
    }

    try {
      final db = await openNotesDb();
      final rows = await db.query('cached_posts', orderBy: 'id ASC', limit: 30);
      return rows.map((r) {
        return Post(
          id: (r['id'] as num?)?.toInt() ?? 0,
          title: r['title'] as String? ?? '',
          body: r['body'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final response = await _dio.get<List<dynamic>>('/posts');
      final rawList = response.data ?? [];
      final freshPosts = rawList
          .take(30)
          .map((item) => Post.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (kIsWeb) {
        _webCachedPosts
          ..clear()
          ..addAll(freshPosts.take(10));
        state = AsyncData(List<Post>.from(_webCachedPosts));
        return;
      }

      final db = await openNotesDb();
      final batch = db.batch();
      batch.delete('cached_posts');
      for (final p in freshPosts) {
        batch.insert('cached_posts', {
          'id': p.id,
          'title': p.title,
          'body': p.body,
          'payload': jsonEncode(p.toJson()),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit(noResult: true);

      // Perbarui state dengan data terbaru setelah background fetch
      state = AsyncData(freshPosts);
    } catch (_) {
      // Jika jaringan offline, pertahankan cache yang sudah ada
    }
  }

  Future<void> refresh() async {
    final isOffline = ref.read(forceOfflineProvider);
    if (isOffline) {
      final cached = await _readCachedPosts();
      state = AsyncData(cached);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _refreshInBackground();
      return _readCachedPosts();
    });
  }
}

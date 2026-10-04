import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/paged_posts.dart';
import '../theme/spotify_theme.dart';
import '../widgets/spotify_post_item_tile.dart';
import '../widgets/spotify_state_views.dart';

/// Halaman Spotify Feeds Mini Project
class SpotifyFeedPage extends ConsumerStatefulWidget {
  const SpotifyFeedPage({super.key});

  @override
  ConsumerState<SpotifyFeedPage> createState() => _SpotifyFeedPageState();
}

class _SpotifyFeedPageState extends ConsumerState<SpotifyFeedPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);

    // Initial Error View
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mini Project Feeds'),
        ),
        body: SpotifyErrorView(
          error: state.error!,
          onRetry: () =>
              ref.read(pagedPostsProvider.notifier).loadFirstPage(),
        ),
      );
    }

    // Initial Loading View
    if (state.items.isEmpty && state.hasMore) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mini Project Feeds'),
        ),
        body: const SpotifyLoadingView(),
      );
    }

    // Empty View
    if (state.items.isEmpty && !state.hasMore) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mini Project Feeds'),
        ),
        body: const SpotifyEmptyView(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: SpotifyTheme.spotifyGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mini Project Feeds',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(pagedPostsProvider.notifier).loadFirstPage(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: SpotifyTheme.spotifyGreen,
        backgroundColor: SpotifyTheme.darkSurface,
        onRefresh: () async {
          await ref.read(pagedPostsProvider.notifier).loadFirstPage();
        },
        child: ListView.builder(
          controller: _controller,
          itemCount: state.items.length + 1,
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              if (!state.hasMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Semua data termuat.',
                      style: TextStyle(
                        color: SpotifyTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: SpotifyTheme.spotifyGreen,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            }
            final post = state.items[index];
            return SpotifyPostItemTile(post: post);
          },
        ),
      ),
    );
  }
}

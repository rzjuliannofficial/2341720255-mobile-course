import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../widgets/post_item_tile.dart';
import '../widgets/post_state_views.dart';

class PostListPage extends ConsumerWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(postListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const PostListLoadingView(),
        error: (err, _) => PostListErrorView(
          error: err,
          onRetry: () => ref.invalidate(postListProvider),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const PostListEmptyView();
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(postListProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) =>
                  PostItemTile(post: posts[index]),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../data/providers.dart';

/// Reusable Widget untuk menampilkan indikator loading
class PostListLoadingView extends StatelessWidget {
  const PostListLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Reusable Widget untuk menampilkan pesan error dan tombol Coba lagi
class PostListErrorView extends StatelessWidget {
  const PostListErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              friendlyErrorMessage(error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Widget untuk menampilkan pesan data kosong
class PostListEmptyView extends StatelessWidget {
  const PostListEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Belum ada data dari server.'),
    );
  }
}

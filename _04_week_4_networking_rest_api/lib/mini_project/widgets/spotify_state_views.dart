import 'package:flutter/material.dart';
import '../../data/providers.dart';
import '../theme/spotify_theme.dart';

/// Loading view bertema Spotify
class SpotifyLoadingView extends StatelessWidget {
  const SpotifyLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: SpotifyTheme.spotifyGreen,
        strokeWidth: 3,
      ),
    );
  }
}

/// Error view bertema Spotify
class SpotifyErrorView extends StatelessWidget {
  const SpotifyErrorView({
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
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SpotifyTheme.darkSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: SpotifyTheme.textNegative,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                friendlyErrorMessage(error),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SpotifyTheme.textBase,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: SpotifyTheme.spotifyGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Text(
                  'COBA LAGI',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty view bertema Spotify
class SpotifyEmptyView extends StatelessWidget {
  const SpotifyEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.library_music_outlined,
            color: SpotifyTheme.textMuted,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada data dari server.',
            style: TextStyle(
              color: SpotifyTheme.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

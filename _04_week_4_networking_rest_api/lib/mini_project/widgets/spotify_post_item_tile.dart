import 'package:flutter/material.dart';
import '../../data/models/post.dart';
import '../theme/spotify_theme.dart';

/// Reusable Card Post untuk Spotify Mini Project
class SpotifyPostItemTile extends StatelessWidget {
  const SpotifyPostItemTile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: SpotifyTheme.darkSurface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SpotifyTheme.midDark,
            borderRadius: BorderRadius.circular(500),
            border: Border.all(color: SpotifyTheme.borderGray, width: 0.8),
          ),
          child: Center(
            child: Text(
              post.id.toString(),
              style: const TextStyle(
                color: SpotifyTheme.spotifyGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          post.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: SpotifyTheme.textBase,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            post.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SpotifyTheme.textMuted,
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: SpotifyTheme.textMuted,
          size: 14,
        ),
      ),
    );
  }
}

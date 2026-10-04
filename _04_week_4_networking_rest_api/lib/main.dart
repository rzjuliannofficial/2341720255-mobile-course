import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mini_project/pages/spotify_feed_page.dart';
import 'mini_project/theme/spotify_theme.dart';
import 'pages/paged_post_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mode Mini Project Spotify (true: SpotifyFeeds, false: PagedPostPage praktikum)
    const bool isMiniProject = true;

    return MaterialApp(
      title: isMiniProject ? 'Mini Project REST API' : 'Week 4 - REST API',
      debugShowCheckedModeBanner: false,
      theme: isMiniProject
          ? SpotifyTheme.darkTheme
          : ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: isMiniProject ? const SpotifyFeedPage() : const PagedPostPage(),
    );
  }
}
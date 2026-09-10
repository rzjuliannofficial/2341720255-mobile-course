import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Tombol di AppBar menuju halaman produk (Riverpod AsyncValue)
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            tooltip: 'Halaman Produk',
            onPressed: () => context.go('/products'),
          ),
          // Tombol menuju AI Challenge StatsPage
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistik (AI Challenge)',
            onPressed: () => context.go('/stats'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item ${index + 1}'),
          onTap: () => context.go('/detail/${index + 1}'),
        ),
      ),
    );
  }
}


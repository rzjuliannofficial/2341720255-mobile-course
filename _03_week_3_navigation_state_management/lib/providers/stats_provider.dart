import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model data statistik aplikasi
class StatItem {
  final String label;
  final String value;

  const StatItem({required this.label, required this.value});
}

/// AsyncNotifier untuk mengelola state data statistik secara asinkron
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  @override
  Future<List<StatItem>> build() async {
    return _fetchStats();
  }

  /// Mengambil data statistik dengan simulasi delay 2 detik dan kegagalan 30%
  Future<List<StatItem>> _fetchStats() async {
    // Simulasi latensi jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi probabilitas kegagalan jaringan 30%
    final random = Random();
    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal memuat data statistik dari server (Koneksi Terputus).');
    }

    // Mengembalikan 3 data statistik jika berhasil (Immutable List)
    return const [
      StatItem(label: 'Total Pengguna Aktif', value: '1.420 User'),
      StatItem(label: 'Total Transaksi Selesai', value: '385 Transaksi'),
      StatItem(label: 'Tingkat Kepuasan Layanan', value: '98.5%'),
    ];
  }

  /// Method untuk merefresh state secara aman dengan AsyncValue.guard
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

/// Provider deklarasi dengan tipe data eksplisit (Modern Riverpod Notifier Pattern)
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
);

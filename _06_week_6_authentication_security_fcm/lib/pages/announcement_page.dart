import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  Map<String, String> _getAnnouncementData(String id) {
    switch (id) {
      case '3':
        return {
          'title': 'Jadwal kuliah berubah',
          'category': 'Akademik',
          'date': 'Hari ini, 13.00 WIB',
          'content':
              'Pemberitahuan kepada seluruh mahasiswa: Perkuliahan Pemrograman Mobile minggu ini dialihkan ke Ruang A2 Gedung Sipil jam 13.00 WIB dikarenakan pemeliharaan laboratorium utama.',
          'sender': 'Biro Administrasi Akademik',
        };
      case '1':
        return {
          'title': 'Pengumuman KRS Semester Ganjil',
          'category': 'Registrasi',
          'date': '10 Oktober 2026',
          'content':
              'Batas akhir persetujuan Kartu Rencana Studi (KRS) oleh Dosen Pembina Akademik (DPA) diperpanjang sampai akhir pekan ini.',
          'sender': 'Bagian Akademik Pusat',
        };
      default:
        return {
          'title': 'Pemberitahuan Kampus #$id',
          'category': 'Umum',
          'date': 'Terkini',
          'content':
              'Detail informasi spesifik untuk pengumuman nomor $id telah berhasil dimuat melalui mekanisme deep linking FCM push notification.',
          'sender': 'Sistem Informasi Kampus',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getAnnouncementData(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Pengumuman #$id'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            data['category']!,
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Deep Link FCM Aktif',
                            style: TextStyle(
                              color: Color(0xFF047857),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['title']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data['sender']} • ${data['date']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Divider(height: 32),
                    Text(
                      data['content']!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF334155),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: Color(0xFF475569)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Target URI: /pengumuman/$id (Payload: {route: /pengumuman/$id, id: $id})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Kembali ke Dashboard'),
                        onPressed: () => context.go(AppRoutes.home),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

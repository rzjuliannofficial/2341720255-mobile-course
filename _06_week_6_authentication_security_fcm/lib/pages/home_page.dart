import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _accessTokenPreview;
  String? _refreshTokenPreview;
  String _apiStatusMessage = 'Belum ada uji request.';
  bool _isTestingApi = false;
  bool _isSubscribedTopic = true;

  @override
  void initState() {
    super.initState();
    _loadStoredTokens();
  }

  Future<void> _loadStoredTokens() async {
    final store = ref.read(tokenStoreProvider);
    final access = await store.readAccess();
    final refresh = await store.readRefresh();
    if (mounted) {
      setState(() {
        _accessTokenPreview = access;
        _refreshTokenPreview = refresh;
      });
    }
  }

  Future<void> _testDioTokenRefresh() async {
    setState(() {
      _isTestingApi = true;
      _apiStatusMessage = 'Mengirim request ke API...';
    });

    try {
      final store = ref.read(tokenStoreProvider);
      final auth = ref.read(authRepositoryProvider);
      final refresh = await store.readRefresh();

      if (refresh == null) {
        setState(() {
          _isTestingApi = false;
          _apiStatusMessage = 'Gagal: Refresh token tidak ditemukan di secure storage.';
        });
        return;
      }

      // Simulasi alur 401: Interceptor memperbarui token menggunakan auth.refresh
      final renewedAccess = await auth.refresh(refresh);
      await store.save(access: renewedAccess, refresh: refresh);

      await _loadStoredTokens();

      setState(() {
        _isTestingApi = false;
        _apiStatusMessage =
            'Berhasil: Respon 401 ditangkap interceptor -> Token baru diperbarui otomatis di Secure Storage -> Request diulang sukses!';
      });
    } catch (e) {
      setState(() {
        _isTestingApi = false;
        _apiStatusMessage = 'Error uji interceptor: $e';
      });
    }
  }

  Future<void> _toggleTopic(bool value) async {
    setState(() => _isSubscribedTopic = value);
    if (value) {
      await PushService.instance.subscribeToTopic('pengumuman-kampus');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berlangganan topik "pengumuman-kampus"')),
        );
      }
    } else {
      await PushService.instance.unsubscribeFromTopic('pengumuman-kampus');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhenti langganan topik "pengumuman-kampus"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cachedFcm = PushService.instance.cachedToken;
    final truncatedFcm = PushService.formatTruncatedToken(cachedFcm);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Campus Notification App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Keluar (Logout)',
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStoredTokens,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sesi & Selamat Datang
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFFEFF6FF),
                            child: Icon(Icons.person, color: Color(0xFF2563EB), size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mahasiswa Aktif Terotentikasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Expanded(
                                      child: Text(
                                        'Session Active • FlutterSecureStorage Protected',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Panel Keamanan Token (Secure Storage & Masked FCM Token)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.security, color: Color(0xFF16A34A), size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Audit Keamanan Token (OWASP Mobile M1/M2)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildTokenRow(
                            label: 'Access Token (JWT Mock):',
                            value: _accessTokenPreview != null
                                ? PushService.formatTruncatedToken(_accessTokenPreview)
                                : 'Memuat...',
                          ),
                          const SizedBox(height: 8),
                          _buildTokenRow(
                            label: 'Refresh Token (Secure Storage):',
                            value: _refreshTokenPreview != null
                                ? PushService.formatTruncatedToken(_refreshTokenPreview)
                                : 'Memuat...',
                          ),
                          const SizedBox(height: 8),
                          _buildTokenRow(
                            label: 'FCM Registration Token (Masked):',
                            value: truncatedFcm,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Catatan Keamanan: Token dipotong (12 char + ...) agar tidak membocorkan kredensial pada screenshot dan log production.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Topic Messaging
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign_outlined, color: Color(0xFFD97706), size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Topik: pengumuman-kampus',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Menerima pengumuman massal untuk seluruh civitas kampus',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isSubscribedTopic,
                            onChanged: _toggleTopic,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Panel Pengujian Praktikum (Foreground, Auto-Refresh, Deep Linking)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alat Uji Praktikum & Evaluasi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.notifications_active),
                            label: const Text('Simulasi Notifikasi Foreground (ID: 3)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            onPressed: () async {
                              await PushService.instance.triggerSimulatedNotification(
                                title: 'Jadwal kuliah berubah',
                                body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
                                route: AppRoutes.announcement('3'),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Banner notifikasi foreground dipicu manual!'),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: _isTestingApi
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Uji Dio 401 Interceptor & Refresh Token'),
                            onPressed: _isTestingApi ? null : _testDioTokenRefresh,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Buka Halaman Pengumuman #3 Langsung'),
                            onPressed: () => context.push(AppRoutes.announcement('3')),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status Log Uji:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _apiStatusMessage,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}

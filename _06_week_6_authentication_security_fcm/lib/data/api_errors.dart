import 'package:dio/dio.dart';

/// Pemetaan DioException ke pesan ramah pengguna berbahasa Indonesia.
/// Memastikan UI menerima pesan deskriptif tanpa mengekspos exception teknis mentah.
String mapDioErrorToMessage(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi ke server waktu habis (timeout). Silakan coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'Sesi autentikasi telah berakhir. Silakan login kembali.';
      }
      if (statusCode == 403) {
        return 'Akses ditolak. Anda tidak memiliki izin untuk tindakan ini.';
      }
      if (statusCode == 404) {
        return 'Data atau endpoint yang diminta tidak ditemukan (404).';
      }
      if (statusCode != null && statusCode >= 500) {
        return 'Terjadi kendala pada server internal ($statusCode).';
      }
      return 'Respon server tidak valid ($statusCode).';
    case DioExceptionType.cancel:
      return 'Permintaan data dibatalkan.';
    case DioExceptionType.badCertificate:
      return 'Sertifikat keamanan server tidak valid.';
    case DioExceptionType.unknown:
      return 'Terjadi kesalahan jaringan atau koneksi tidak dikenal.';
  }
}

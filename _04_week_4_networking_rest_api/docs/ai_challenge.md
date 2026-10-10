# Catatan Teknis & Dokumentasi AI Challenge: Comment Repository Layer

## 1. Prompt yang Digunakan

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal AI & Evaluasi Kritis

### A. Output Awal

- AI menghasilkan model `Comment`, kelas `CommentRepository`, serta notifier Riverpod.
- Namun, output awal AI menggunakan `StateProvider` yang sudah usang (*deprecated*) pada Riverpod 3.x dan mencoba memanggil `FamilyAsyncNotifier` dengan sintaks usang.
- Parsing tipe numerik `(json['postId'] as int)` rentan crash jika backend mengembalikan tipe `double` atau `num`.

### B. Perbaikan yang Dilakukan (*Refactoring & Engineering*)

1. **Peningkatan Ketahanan Null-Safety Model**:
   - Mengganti `(json['postId'] as int)` menjadi `(json['postId'] as num?)?.toInt() ?? 0` agar aman dari tipe numerik tak terduga ataupun `null`.
   - Menambahkan default fallback string kosong `''` pada semua field string.
2. **Kesesuaian Riverpod 3.x**:
   - Menggunakan `NotifierProvider<SelectedPostIdNotifier, int>` menggantikan `StateProvider`.
   - Menggunakan `AsyncNotifier<List<Comment>>` dengan `ref.watch(selectedPostIdProvider)` sehingga saat ID berubah, daftar komentar otomatis diperbarui secara deklaratif.
3. **Pemusatan Konfigurasi Jaringan**:
   - Menggunakan `dioProvider` terpusat dari [api_client.dart](file:///c:/laragon/www/Kuliah/2341720255-mobile-course/_04_week_4_networking_rest_api/lib/data/api_client.dart) dan menambahkan eksplisit `Options(sendTimeout: 10s, receiveTimeout: 10s)`.
4. **Penambahan Edge-Case Unit Test**:
   - Menambahkan pengujian tipe data numerik tidak terduga (`double` ke `int`) dan `null` eksplisit.
   - Menambahkan pengujian pemetaan `commentErrorMessage` untuk timeout, HTTP 404, dan HTTP 500.

---

## 3. Hasil Testing & Analisis

- Perintah test: `flutter test test/comment_test.dart`
- Status: **5/5 tests passed** tanpa error.
- Analisis statis: Kode mematuhi aturan strict linting tanpa peringatan (*no warnings*).

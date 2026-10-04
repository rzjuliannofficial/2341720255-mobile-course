# Laporan Praktikum Minggu 4: Networking & REST API


| Data Mahasiswa     | Keterangan                           |
| :------------------- | :------------------------------------- |
| **Mata Kuliah**    | Pemrograman Mobile                   |
| **Dosen Pengampu** | Agung Nugroho Pramudhita, S.T., M.T. |
| **Nama Mahasiswa** | Nabhan Rizqi Julian Saputro          |
| **NIM**            | `2341720255`                         |
| **Kelas**          | TI - 3F                              |
| **Minggu / Modul** | Minggu 04 - Networking & REST API    |

---

## Praktikum 2: Provider dan Error Handling

### 1. Skenario 1: Internet Normal

- **Deskripsi**: Menjalankan aplikasi dengan koneksi internet aktif, menampilkan indikator *loading*, lalu berhasil memuat daftar 100 data post dari REST API.
- **Bukti Screenshot**:

  ![Skenario 1 - Internet Normal](screenshots/praktikum_2_skenario_1.png)

---

### 2. Skenario 2: Mode Pesawat / Tanpa Internet (Offline) & Coba Lagi

- **Deskripsi**: Menyalakan mode pesawat, menekan tombol refresh, sistem menangkap error dan menampilkan pesan ramah serta tombol **Coba lagi**. Setelah internet diaktifkan kembali dan tombol **Coba lagi** ditekan, data berhasil dimuat kembali.
- **Bukti Screenshot**:

  ![Skenario 2 - Mode Pesawat / Offline](screenshots/praktikum_2_skenario_2.png)

---

### 3. Skenario 3: Base URL Salah (Connection Error)

- **Deskripsi**: Mengubah `baseUrl` menjadi URL yang salah pada konfigurasi Dio, mengamati penanganan pesan error koneksi pada UI, kemudian mengembalikan URL ke nilai semula.
- **Bukti Screenshot**:

  ![Skenario 3 - Base URL Salah](screenshots/praktikum_2_skenario_3.png)

---

## Praktikum 3: Pagination Dasar (Infinite Scroll)

### 1. Bukti Halaman Pertama (Page 1)

- **Deskripsi**: Menampilkan 10 item awal pertama (`_page=1&_limit=10`) saat aplikasi pertama kali dimuat.
- **Bukti Screenshot**:

  ![Praktikum 3 - Page 1 Awal](screenshots/praktikum_3_page_1.png)

---

### 2. Bukti Infinite Scroll (Loading More & Data Bertambah)

- **Deskripsi**: Saat layar di-scroll mendekati batas bawah, indikator loading kecil (*CircularProgressIndicator*) muncul di bawah list, kemudian 10 data berikutnya bertambah secara mulus tanpa melakukan reload penuh ke seluruh layar.
- **Bukti Screenshot**:

  ![Praktikum 3 - Load More & Bertambah](screenshots/praktikum_3_load_more.png)

---

## AI Challenge: Repository Layer & Verification Checklist

### 1. Prompt AI yang Digunakan

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

### 2. Tabel AI Verification Checklist


| No | Poin Verifikasi Checklist                |  Status  | Catatan Temuan & Keputusan Teknis                                                                                                   |
| :--- | :----------------------------------------- | :--------: | :------------------------------------------------------------------------------------------------------------------------------------ |
| 1  | **UI Memanggil Dio Langsung?**           | ✅ Lolos | UI dilarang memanggil Dio secara langsung. Akses jaringan diisolasi penuh melalui`CommentRepository`.                               |
| 2  | **`fromJson` Aman Null?**                | ✅ Lolos | Parsing menggunakan casting aman`(json['postId'] as num?)?.toInt() ?? 0` dan fallback `''`, bebas crash dari tipe data tak terduga. |
| 3  | **Pemetaan `DioExceptionType` Lengkap?** | ✅ Lolos | Menangani timeout (send/receive/connect),`connectionError`, HTTP 404, serta HTTP 500 melalui fungsi `commentErrorMessage`.          |
| 4  | **Pemusatan `baseUrl` dan Timeout?**     | ✅ Lolos | Menggunakan instance`dioProvider` terpusat dari `api_client.dart` dengan tambahan batas waktu 10 detik di repository.               |
| 5  | **Pengujian Field Hilang & Edge Case?**  | ✅ Lolos | Unit test menguji field hilang/null serta edge-case tipe data pecahan (`double` ke `int`) dan pemetaan pesan error.                 |
| 6  | **Hasil Analisis & Testing Otomatis?**   | ✅ Lolos | Seluruh 5 unit test pada`test/comment_test.dart` lulus 100% tanpa error (`All tests passed`).                                       |

---

### 3. Bukti Pengujian Unit Test AI Challenge

- **Deskripsi**: Hasil eksekusi unit test `flutter test test/comment_test.dart` yang menguji integritas model dan pemetaan pesan error.
- **Bukti Screenshot / Log Output**:

  ![AI Challenge - Test Passed](screenshots/ai_challenge_test_passed.png)

---

## Refactoring dan Testing

### 1. Refactoring Komponen UI (Modular Widgets)

- **Deskripsi**: Memisahkan antarmuka `PostListPage` menjadi modul widget terisolasi di folder `lib/widgets/`:
  - `PostItemTile`: Komponen item baris list post.
  - `PostListLoadingView`: Komponen indikator loading.
  - `PostListErrorView`: Komponen tampilan error beserta tombol retry.
  - `PostListEmptyView`: Komponen data kosong.
- **Tujuan**: Meningkatkan *reusability*, mempermudah *maintenance*, dan menjaga kode UI tetap bersih (*Clean Code*).

---

### 2. Testing Provider & Repository (Fake/Mock Repository)

- **Deskripsi**: Menjalankan pengujian otomatis unit test di `test/post_test.dart` menggunakan `FakePostRepository` dan helper `readPostsOnce` serta `readPostsErrorOnce`.
- **Hasil Pengujian**: Seluruh 6 unit test berhasil lulus 100% tanpa kendala jaringan sungguhan (*isolated testing*).
- **Bukti Screenshot / Output Terminal**:

  ![Praktikum 7 - Test Passed](screenshots/praktikum_7_test_passed.png)

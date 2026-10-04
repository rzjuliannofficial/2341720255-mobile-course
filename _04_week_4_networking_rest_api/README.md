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


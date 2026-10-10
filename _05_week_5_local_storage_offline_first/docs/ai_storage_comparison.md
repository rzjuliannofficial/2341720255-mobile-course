# Dokumentasi AI Challenge: Analisis & Perbandingan Local Storage Flutter

Dokumen ini berisi hasil pengujian prompt AI, evaluasi kritis, tabel perbandingan teknis, serta verifikasi arsitektur penyimpanan lokal untuk aplikasi Flutter **Offline Notes**.

---

## 1. Prompt AI yang Digunakan

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

---

## 2. Tabel Perbandingan Teknis Local Storage

| Kriteria Evaluasi | SharedPreferences | Hive (NoSQL Key-Value) | sqflite (SQLite C API) | Drift (SQLite Reactive) |
| :--- | :--- | :--- | :--- | :--- |
| **Model Data** | Key-Value primitif | NoSQL Document / Box | Relasional SQL (Tabel) | Relasional SQL Type-Safe |
| **Kompleksitas Query** | Sangat Rendah (Key lookup) | Rendah (Filter in-memory) | Sangat Tinggi (SQL murni, JOIN, GROUP) | Sangat Tinggi (Dart DSL / SQL murni) |
| **Kebutuhan Relasi** | Tidak mendukung | Tidak mendukung (manual link) | Penuh (Foreign Key, Indexes) | Penuh (Foreign Key, Type-safe JOIN) |
| **Reaktivitas (Stream)** | Manual / Notifier | Mendukung `watch()` Box | Perlu wrapper / Riverpod Notifier | Sangat Reaktif (Stream terintegrasi bawaan) |
| **Type-Safety** | Primitif runtime casting | Perlu TypeAdapter generator | Manual Map mapping (`fromMap`) | Penuh (Compile-time code generation) |
| **Ukuran Boilerplate** | Sangat Kecil (zero-config) | Sedang (TypeAdapter) | Sedang (SQL string, migrasi manual) | Tinggi (Build runner, generated tables) |
| **Kemudahan Testing** | Sangat Mudah (Mock initial values) | Sedang (Directory mock/in-memory) | Sangat Mudah (Injeksi Fake Repo / FFI) | Sedang (Mock in-memory connection) |
| **Performa 1000+ Item** | Buruk jika simpan JSON raksasa | Sangat Cepat (In-memory index) | Cepat (B-Tree SQLite on-disk, paging) | Cepat (B-Tree SQLite on-disk, paging) |

---

## 3. Rekomendasi Final & Keputusan Arsitektur

| Kebutuhan Fitur | Teknologi Terpilih | Alasan & Justifikasi Teknis |
| :--- | :--- | :--- |
| **Preferensi Tema & Riwayat Buka** | `SharedPreferences` | Data bernilai primitif kecil (boolean `dark_mode`, string ISO `last_opened_at`). Tidak membutuhkan relasi, zero-overhead, dan native platform binding. |
| **Koleksi Catatan & Cache Posts** | `sqflite (SQLite)` | Mendukung struktur data relasional, pengurutan `updated_at DESC`, query parsial, indexing, serta kolom `dirty` untuk sinkronisasi tanpa membebani memori RAM. |

---

## 4. Skema Database (Untuk 1000+ Catatan & Antrean Sync)

```sql
-- Skema Tabel Catatan (SQLite)
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    body TEXT NOT NULL DEFAULT '',
    updated_at TEXT NOT NULL,
    dirty INTEGER NOT NULL DEFAULT 0
);

-- Index untuk mempercepat query pengurutan dan filter antrean sync
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);

-- Skema Tabel Cache Posts (Cache-First Read API)
CREATE TABLE cached_posts (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL DEFAULT '',
    body TEXT NOT NULL DEFAULT '',
    payload TEXT NOT NULL,
    cached_at TEXT NOT NULL
);
```

---

## 5. AI Verification Checklist

1. **Apakah AI menempatkan daftar catatan di SharedPreferences?**
   - **Keputusan**: DITOLAK. Menyimpan daftar catatan sebagai satu string JSON besar di SharedPreferences sangat rapuh, tidak efisien untuk pembaruan sebagian (partial update), membebani I/O disk, dan meniadakan fitur indexing/query SQL.
2. **Apakah skema AI mendukung antrean sync (dirty flag / updated_at)?**
   - **Keputusan**: DIVERIFIKASI. Skema SQLite wajib menyertakan flag `dirty` (INTEGER 0/1) dan timestamp `updated_at` (ISO-8601) untuk mendukung antrean sinkronisasi offline serta resolusi konflik *Last-Write-Wins*.
3. **Apakah klaim "real-time" AI didukung stream atau hanya asumsi?**
   - **Keputusan**: DIVERIFIKASI. Pada sqflite, reaktivitas ditangani secara bersih melalui arsitektur Riverpod (`AsyncNotifierProvider` + `ref.invalidate()` / `refresh()`). Drift menyediakan stream bawaan namun membutuhkan dependensi generator `build_runner` yang berat.
4. **Apakah estimasi boilerplate AI masuk akal?**
   - **Keputusan**: Sesuai fakta teknis. Drift memang membutuhkan waktu kompilasi code-gen yang lebih panjang, sementara `sqflite` memberikan kendali penuh dengan boilerplate moderat.

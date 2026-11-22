# Pengujian Data — Campus Lost & Found

Dokumen ini berisi dua jenis pengujian:

- **A. Pengujian otomatis** — komputer yang mengecek fungsi pengolah data.
- **B. Pengujian manual** — kita mencoba aplikasi lalu mencocokkan datanya dengan Firebase.

## A. Pengujian Otomatis

File: `test/report_helpers_test.dart`. Cara menjalankan: buka terminal di folder proyek, ketik `flutter test`.

**Hasil: 13 tes, semuanya lulus (`All tests passed!`).**

| No | Yang diuji | Hasil yang diharapkan |
|---|---|---|
| 1 | `reportText`, field ada | Mengembalikan teks field |
| 2 | `reportText`, field tidak ada | Mengembalikan `-` |
| 3 | `reportText`, field `null` | Mengembalikan `-` |
| 4 | `reportText`, field kosong dengan fallback `x` | Mengembalikan `x` |
| 5 | `reportText`, field berisi angka | Angka diubah menjadi teks |
| 6 | `reportDate`, diberi Timestamp 5 Maret 2026 | `5/3/2026` |
| 7 | `reportDate`, bukan Timestamp | `-` |
| 8 | `ProfileStats`, data kosong | Semua hitungan 0 |
| 9 | `ProfileStats`, data campuran | Jumlah hilang/ditemukan/aktif/selesai benar |
| 10 | `ProfileStats`, tanpa field status | Dihitung sebagai aktif |

## B. Pengujian Manual

### Persiapan

1. Buka folder proyek di VS Code, lalu jalankan `git pull` agar kode paling baru.
2. Jalankan aplikasi dengan `flutter run` (pilih emulator atau HP, atau Chrome).
3. Di browser, buka **Firebase Console → Firestore Database → koleksi `reports`**. Biarkan terbuka di samping aplikasi untuk mencocokkan data.

Menu bawah aplikasi: **Beranda, Pencarian, Lapor, Laporan Saya, Profil**.

### Tabel pengujian

Isi kolom *Hasil aktual* dengan apa yang benar-benar terjadi, dan kolom *Status* dengan **Lulus** atau **Gagal**.

| ID | Yang diuji | Langkah | Hasil yang diharapkan | Hasil aktual | Status |
|---|---|---|---|---|---|
| D-01 | Login anonim | Buka aplikasi, klik menu **Profil** | Tertulis "Mode tamu (anonim)" dan ID sesi terisi | | |
| D-02 | Salin ID sesi | Di Profil, tekan ikon salin | Muncul pesan "ID sesi disalin" | | |
| D-03 | Buat laporan hilang | Menu **Lapor** → Jenis: Hilang → isi semua kolom → kirim | Muncul notifikasi berhasil; di Firestore ada dokumen baru dengan `reportType = hilang`, `status = aktif`, `userId` sama dengan ID di Profil | | |
| D-04 | Buat laporan ditemukan | Sama seperti D-03, pilih Ditemukan | Dokumen baru dengan `reportType = ditemukan` | | |
| D-05 | Kolom wajib kosong | Menu **Lapor**, kosongkan Nama Barang, tekan kirim | Muncul pesan kolom wajib diisi, tidak ada dokumen baru di Firestore | | |
| D-06 | Waktu otomatis | Lihat dokumen hasil D-03 di Firestore | `createdAt` dan `updatedAt` terisi tanggal dan jam | | |
| D-07 | Laporan Saya | Menu **Laporan Saya** | Laporan D-03 dan D-04 muncul; data contoh milik `user_demo` tidak muncul | | |
| D-08 | Filter di Laporan Saya | Tekan **Hilang**, lalu **Ditemukan**, lalu **Semua** | Daftar menyesuaikan jenis laporan | | |
| D-09 | Selesaikan laporan | Di Laporan Saya, tekan tombol selesai pada laporan aktif → **Ya, selesai** | `status` di Firestore berubah jadi `selesai` dan `updatedAt` ikut berubah | | |
| D-10 | Ringkasan Profil | Menu **Profil** | Angka total, hilang, ditemukan, aktif, selesai sama dengan isi Laporan Saya | | |
| D-11 | Real-time | Ubah `status` salah satu dokumen langsung di Firestore (`aktif` ↔ `selesai`) | Angka di Profil berubah tanpa menutup aplikasi | | |
| D-12 | Beranda dan Pencarian | Menu **Beranda**, lalu **Pencarian**, cari nama barang yang dibuat di D-03 | Laporan baru tampil; filter jenis dan status bekerja | | |
| D-13 | Detail dan WhatsApp | Buka satu laporan → tekan **Hubungi Pelapor** | WhatsApp terbuka ke nomor di kolom kontak (jika WhatsApp terpasang) | | |
| D-14 | Tanpa foto | Buat laporan tanpa foto | Laporan tetap tersimpan, kartu tampil dengan gambar pengganti, tidak error | | |
| D-15 | Sesi baru | Hapus data aplikasi (atau pakai perangkat lain), buka lagi | ID sesi di Profil berbeda; Laporan Saya kosong; laporan lama tetap ada di Beranda | | |

> Catatan: kalau ada skenario yang tidak bisa dicoba karena fiturnya belum ada di aplikasi, tulis **"Fitur belum ada"** di kolom *Hasil aktual*.

### Setelah pengujian

- Hapus dokumen uji dari Firestore agar data demo tetap bersih.
- Jika ada yang **Gagal**, catat langkah yang dilakukan dan pesan error-nya, lalu sampaikan ke anggota tim yang mengerjakan fitur itu.

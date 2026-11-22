# Pengujian Data — Campus Lost & Found

## A. Pengujian Otomatis (unit test)

File: `test/report_helpers_test.dart`

Jalankan:

```bash
flutter test
```

| No | Yang diuji | Hasil yang diharapkan |
|---|---|---|
| 1 | `reportText` field ada | Mengembalikan teks field |
| 2 | `reportText` field tidak ada / null / kosong | Mengembalikan fallback (`—` atau nilai yang diberikan) |
| 3 | `reportDate` dengan Timestamp | Format `dd/MM/yyyy` (mis. `05/03/2026`) |
| 4 | `reportDate` bukan Timestamp | `Tanggal belum ada` |
| 5 | `ProfileStats` data kosong | Semua hitungan 0 |
| 6 | `ProfileStats` campuran data | Jumlah hilang/ditemukan/aktif/selesai benar |
| 7 | `ProfileStats` tanpa field status | Dihitung sebagai aktif |

## B. Pengujian Manual (aplikasi + Firebase Console)

Jalankan `flutter run`, lalu buka **Firebase Console → Firestore → reports** untuk mencocokkan data.

| ID | Skenario | Langkah | Hasil yang diharapkan | Hasil aktual | Status |
|---|---|---|---|---|---|
| D-01 | Login anonim | Buka aplikasi pertama kali | Tab Profil menampilkan "Mode tamu (anonim)" dan UID terisi; user muncul di Authentication | | |
| D-02 | Buat laporan hilang | Tab Lapor → isi semua field → Kirim | Dokumen baru di `reports`: `reportType=hilang`, `status=aktif`, `userId`=UID Profil | | |
| D-03 | Buat laporan ditemukan | Sama dengan D-02, pilih Ditemukan | `reportType=ditemukan` | | |
| D-04 | Field wajib kosong | Kirim form dengan nama barang kosong | Form menolak, tidak ada dokumen baru | | |
| D-05 | Timestamp server | Cek dokumen hasil D-02 | `createdAt` dan `updatedAt` terisi timestamp | | |
| D-06 | Laporan Saya | Buka tab Laporan Saya | Laporan D-02 & D-03 muncul, data seed (`user_demo`) tidak muncul | | |
| D-07 | Selesaikan laporan | Tekan tombol selesai pada laporan aktif | `status=selesai`, `updatedAt` berubah | | |
| D-08 | Ringkasan Profil | Buka tab Profil setelah D-02 s/d D-07 | Total/hilang/ditemukan/aktif/selesai cocok dengan isi Laporan Saya | | |
| D-09 | Real-time | Ubah `status` langsung di Firebase Console | Angka Profil dan daftar berubah tanpa restart | | |
| D-10 | Beranda & Pencarian | Cek Beranda dan cari nama barang | Laporan baru tampil; filter jenis/status sesuai | | |
| D-11 | Dokumen tanpa `imageUrl` | Buat laporan tanpa foto | Kartu tampil dengan ikon placeholder, tidak error | | |
| D-12 | Offline | Matikan internet, buka Profil | Tidak crash; data cache atau indikator loading tampil | | |
| D-13 | Sesi baru | Hapus data aplikasi, buka ulang | UID baru; Laporan Saya kosong; laporan lama tetap ada di Beranda | | |

Kolom *Hasil aktual* dan *Status* (Lulus/Gagal) diisi saat pengujian dijalankan.

## C. Catatan

- Pengujian D-xx membutuhkan perangkat/emulator dengan koneksi ke project Firebase yang sama dengan `firebase_options.dart`.
- Hapus dokumen uji dari Firestore setelah pengujian agar data demo tetap bersih.

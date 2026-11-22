# Dokumentasi Database — Campus Lost & Found

Database: **Cloud Firestore** (NoSQL, berbasis dokumen). Autentikasi: **Firebase Authentication (anonim)**.

## 1. Struktur Koleksi

```
Firestore
└── reports (collection)
    └── {documentId}  ← ID otomatis dari Firestore (add())
```

Hanya ada satu koleksi: **`reports`**. Laporan barang hilang dan barang ditemukan disimpan di koleksi yang sama, dibedakan oleh field `reportType`.

## 2. Skema Dokumen `reports`

| Field | Tipe | Wajib | Nilai / Keterangan |
|---|---|---|---|
| `reportType` | string | Ya | `hilang` atau `ditemukan` |
| `itemName` | string | Ya | Nama barang (sudah di-`trim`) |
| `category` | string | Ya | `Elektronik`, `Dokumen`, `Aksesoris`, `Perlengkapan`, `Lainnya` |
| `location` | string | Ya | Lokasi kejadian |
| `eventDate` | timestamp | Ya | Tanggal barang hilang / ditemukan |
| `eventTime` | string | Ya | Jam kejadian (teks) |
| `description` | string | Ya | Ciri-ciri / keterangan barang |
| `contact` | string | Ya | Kontak pelapor (nomor WhatsApp) |
| `imageUrl` | string | Tidak | Alamat/URL foto; boleh kosong `""` (foto belum diunggah ke Firebase Storage) |
| `status` | string | Ya | `aktif` (default saat dibuat) atau `selesai` |
| `userId` | string | Ya | UID Firebase Auth pembuat laporan |
| `createdAt` | timestamp | Ya | `FieldValue.serverTimestamp()` saat dibuat |
| `updatedAt` | timestamp | Ya | Diperbarui saat dibuat dan saat status berubah |

### Contoh dokumen

```json
{
  "reportType": "hilang",
  "itemName": "Dompet Hitam",
  "category": "Aksesoris",
  "location": "Perpustakaan Lantai 2",
  "eventDate": "2026-11-20T00:00:00Z",
  "eventTime": "14:30",
  "description": "Dompet kulit hitam berisi KTM dan SIM",
  "contact": "081234567890",
  "imageUrl": "",
  "status": "aktif",
  "userId": "AbCdEf123UidFirebase",
  "createdAt": "<serverTimestamp>",
  "updatedAt": "<serverTimestamp>"
}
```

## 3. Operasi Data (`ReportService`)

| Method | Operasi Firestore | Dipakai oleh |
|---|---|---|
| `watchAll()` | `reports.snapshots()` | Beranda, Pencarian |
| `watchMine()` | `reports.where('userId', isEqualTo: uid).snapshots()` | Laporan Saya, Profil |
| `create(...)` | `reports.add({...})` dengan `status: 'aktif'` | Form Lapor |
| `finish(id)` | `update({status: 'selesai', updatedAt})` | Laporan Saya |

Filter jenis, status, dan kata kunci pada halaman Pencarian dilakukan **di sisi aplikasi** (client-side) dari hasil `watchAll()`.

### Fungsi bantu (di `report_service.dart`)

| Fungsi | Kegunaan | Hasil |
|---|---|---|
| `reportText(data, key, fallback)` | Mengambil teks dari field dokumen | Teks field, atau `-` jika kosong/tidak ada |
| `reportDate(value)` | Mengubah `Timestamp` menjadi teks tanggal | Format `d/M/yyyy` (mis. `5/3/2026`), atau `-` jika bukan Timestamp |

## 4. Alur Status Laporan

```
(dibuat) ──► aktif ──finish()──► selesai
```

Tidak ada perpindahan balik dari `selesai` ke `aktif` di aplikasi saat ini.

## 5. Autentikasi

Aplikasi memakai **Firebase Authentication** dengan dua cara masuk:

| Cara masuk | Metode Firebase | Keterangan |
|---|---|---|
| Email dan kata sandi | `signInWithEmailAndPassword` / `createUserWithEmailAndPassword` | Daftar menyimpan nama lengkap sebagai `displayName` |
| Lanjutkan sebagai Tamu | `signInAnonymously` | Akun anonim, tanpa nama dan email |

**Alur aplikasi:** buka aplikasi → `AuthGate` memeriksa sesi → belum login: halaman Masuk/Daftar; sudah login: dashboard. Login otomatis diingat Firebase, jadi pengguna tidak perlu masuk lagi saat membuka aplikasi berikutnya, sampai menekan **Keluar** di halaman Profil.

**Data akun** (disimpan Firebase Authentication, bukan Firestore):

| Data | Sumber di aplikasi |
|---|---|
| `uid` | ID unik akun; disalin ke field `userId` pada setiap laporan |
| `displayName` | Nama lengkap saat Daftar |
| `email` | Email saat Daftar |
| `isAnonymous` | `true` jika masuk sebagai Tamu |

**Catatan penting**

- Syarat awal: di Firebase Console → **Authentication → Sign-in method**, metode **Email/Password** dan **Anonymous** harus berstatus *Enabled*.
- Kata sandi minimal 6 karakter (aturan Firebase) dan tidak pernah disimpan di Firestore.
- Laporan terikat pada `uid`. Laporan yang dibuat sebagai Tamu **tidak** ikut pindah ke akun terdaftar, karena `uid`-nya berbeda.
- Jika data aplikasi dihapus saat masih sebagai Tamu, `uid` berubah dan laporan lama tidak muncul lagi di "Laporan Saya".
- Data contoh (seed) memakai `userId: "user_demo"`, sehingga hanya muncul di Beranda/Pencarian, tidak di Laporan Saya.
- Pesan error Firebase diterjemahkan ke bahasa Indonesia oleh `authErrorMessage()` di `auth_service.dart`.

## 6. Indeks

Query yang dipakai hanya satu filter kesetaraan (`userId ==`) tanpa `orderBy`, sehingga **tidak memerlukan composite index**. Jika nanti ditambah `orderBy('createdAt')` pada `watchMine()`, Firestore akan meminta composite index (`userId` ASC + `createdAt` DESC); ikuti tautan pembuatan indeks yang muncul di log error.

## 7. Usulan Firestore Security Rules

Rules ini **usulan** — periksa dulu rules yang aktif di Firebase Console sebelum mengganti, dan uji di tab *Rules Playground*.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /reports/{reportId} {
      allow read: if request.auth != null;

      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.reportType in ['hilang', 'ditemukan']
        && request.resource.data.status == 'aktif';

      // Hanya pemilik yang boleh mengubah, dan hanya status/updatedAt
      allow update: if request.auth != null
        && resource.data.userId == request.auth.uid
        && request.resource.data.diff(resource.data)
             .affectedKeys().hasOnly(['status', 'updatedAt']);

      allow delete: if false;
    }
  }
}
```

## 8. Catatan & Keterbatasan

- `contact` (nomor WhatsApp) tersimpan sebagai teks biasa dan terbaca oleh semua pengguna yang login; ini disengaja agar penemu/pemilik bisa saling menghubungi.
- `imageUrl` hanya menyimpan teks alamat foto; Firebase Storage belum dipakai.
- Tombol "Hubungi Pelapor" di halaman Detail memakai nilai field `contact` untuk membuka WhatsApp (paket `url_launcher`). Nomor yang salah format akan membuat WhatsApp gagal terbuka.
- Pencarian client-side mengunduh semua dokumen `reports`; untuk data besar perlu paginasi atau query terindeks.

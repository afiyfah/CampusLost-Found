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
| `imageUrl` | string | Tidak | URL foto; boleh kosong `""` |
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

## 4. Alur Status Laporan

```
(dibuat) ──► aktif ──finish()──► selesai
```

Tidak ada perpindahan balik dari `selesai` ke `aktif` di aplikasi saat ini.

## 5. Autentikasi

- `main.dart` memanggil `signInAnonymously()` bila belum ada sesi.
- `userId` pada laporan = `FirebaseAuth.instance.currentUser.uid`.
- Akun anonim terikat pada perangkat/sesi; jika data aplikasi dihapus, UID berubah dan laporan lama tidak muncul lagi di "Laporan Saya".
- Data contoh (seed) memakai `userId: "user_demo"`, sehingga hanya muncul di Beranda/Pencarian, tidak di Laporan Saya.

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
- `imageUrl` hanya menyimpan URL; Firebase Storage belum dipakai.
- Pencarian client-side mengunduh semua dokumen `reports`; untuk data besar perlu paginasi atau query terindeks.

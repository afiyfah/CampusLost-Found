import 'package:firebase_auth/firebase_auth.dart';

/// Pembungkus Firebase Authentication.
class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Akun sudah jadi; kegagalan menyimpan nama tidak boleh
    // membuat pendaftaran dianggap gagal.
    try {
      await cred.user?.updateDisplayName(name.trim());
    } catch (_) {}
  }

  static Future<void> signInAsGuest() async {
    await _auth.signInAnonymously();
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}

// ---------- Validasi form ----------

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nama lengkap wajib diisi';
  }
  return null;
}

String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Email wajib diisi';
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(text)) return 'Format email tidak valid';
  return null;
}

/// Dipakai di form Daftar (minimal 6 karakter, aturan Firebase).
String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Kata sandi wajib diisi';
  }
  if (value.length < 6) return 'Kata sandi minimal 6 karakter';
  return null;
}

/// Dipakai di form Masuk (hanya cek tidak kosong).
String? validateRequiredPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Kata sandi wajib diisi';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Konfirmasi kata sandi wajib diisi';
  }
  if (value != password) return 'Konfirmasi kata sandi tidak sama';
  return null;
}

// ---------- Pesan error ----------

String authErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Format email tidak valid.';
    case 'user-disabled':
      return 'Akun ini dinonaktifkan.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email atau kata sandi salah.';
    case 'email-already-in-use':
      return 'Email sudah terdaftar. Silakan masuk.';
    case 'weak-password':
      return 'Kata sandi terlalu lemah (minimal 6 karakter).';
    case 'operation-not-allowed':
      return 'Metode login ini belum diaktifkan di Firebase.';
    case 'network-request-failed':
      return 'Tidak ada koneksi internet.';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    default:
      return 'Terjadi kesalahan ($code). Coba lagi.';
  }
}

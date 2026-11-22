import 'package:campuslostandfound/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateName', () {
    test('kosong ditolak', () {
      expect(validateName(''), isNotNull);
      expect(validateName('   '), isNotNull);
      expect(validateName(null), isNotNull);
    });

    test('terisi diterima', () {
      expect(validateName('Nabila'), isNull);
    });
  });

  group('validateEmail', () {
    test('kosong ditolak', () {
      expect(validateEmail(''), 'Email wajib diisi');
      expect(validateEmail(null), 'Email wajib diisi');
    });

    test('format salah ditolak', () {
      expect(validateEmail('nabila'), 'Format email tidak valid');
      expect(validateEmail('nabila@'), 'Format email tidak valid');
      expect(validateEmail('nabila@mail'), 'Format email tidak valid');
      expect(validateEmail('na bila@mail.com'),
          'Format email tidak valid');
    });

    test('format benar diterima', () {
      expect(validateEmail('nama@students.ac.id'), isNull);
      expect(validateEmail('  nama@students.ac.id  '), isNull);
    });
  });

  group('validateNewPassword', () {
    test('kosong ditolak', () {
      expect(validateNewPassword(''), isNotNull);
      expect(validateNewPassword(null), isNotNull);
    });

    test('kurang dari 6 karakter ditolak', () {
      expect(validateNewPassword('12345'), isNotNull);
    });

    test('6 karakter atau lebih diterima', () {
      expect(validateNewPassword('123456'), isNull);
    });
  });

  group('validateRequiredPassword', () {
    test('kosong ditolak, terisi diterima', () {
      expect(validateRequiredPassword(''), isNotNull);
      expect(validateRequiredPassword('abc'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('kosong ditolak', () {
      expect(validateConfirmPassword('', 'abc123'), isNotNull);
    });

    test('tidak sama ditolak', () {
      expect(validateConfirmPassword('abc124', 'abc123'),
          'Konfirmasi kata sandi tidak sama');
    });

    test('sama diterima', () {
      expect(validateConfirmPassword('abc123', 'abc123'), isNull);
    });
  });

  group('authErrorMessage', () {
    test('kredensial salah', () {
      const msg = 'Email atau kata sandi salah.';
      expect(authErrorMessage('invalid-credential'), msg);
      expect(authErrorMessage('user-not-found'), msg);
      expect(authErrorMessage('wrong-password'), msg);
    });

    test('email sudah terdaftar', () {
      expect(authErrorMessage('email-already-in-use'),
          contains('sudah terdaftar'));
    });

    test('tidak ada internet', () {
      expect(authErrorMessage('network-request-failed'),
          contains('internet'));
    });

    test('kode tak dikenal memuat kodenya', () {
      expect(authErrorMessage('xyz'), contains('xyz'));
    });
  });
}

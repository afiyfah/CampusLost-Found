import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campuslostandfound/pages/profile_page.dart';
import 'package:campuslostandfound/services/report_service.dart';

void main() {
  group('reportText', () {
    test('mengembalikan teks jika field ada', () {
      expect(reportText({'itemName': 'Dompet'}, 'itemName'), 'Dompet');
    });

    test('fallback default "-" jika field tidak ada', () {
      expect(reportText({}, 'itemName'), '-');
    });

    test('fallback jika field null', () {
      expect(reportText({'location': null}, 'location'), '-');
    });

    test('fallback jika field string kosong', () {
      expect(reportText({'imageUrl': ''}, 'imageUrl', 'x'), 'x');
    });

    test('angka diubah menjadi teks', () {
      expect(reportText({'n': 5}, 'n'), '5');
    });
  });

  group('reportDate', () {
    test('format dd/MM/yyyy', () {
      final ts = Timestamp.fromDate(DateTime(2026, 3, 5));
      expect(reportDate(ts), '5/3/2026');
    });

    test('bukan Timestamp -> pesan default', () {
      expect(reportDate(null), '-');
      expect(reportDate('2026-03-05'), '-');
    });
  });

  group('ProfileStats', () {
    test('data kosong -> semua 0', () {
      final s = ProfileStats.fromData([]);
      expect(s.total, 0);
      expect(s.lost, 0);
      expect(s.found, 0);
      expect(s.active, 0);
      expect(s.finished, 0);
    });

    test('menghitung tipe dan status dengan benar', () {
      final s = ProfileStats.fromData([
        {'reportType': 'hilang', 'status': 'aktif'},
        {'reportType': 'hilang', 'status': 'selesai'},
        {'reportType': 'ditemukan', 'status': 'aktif'},
      ]);
      expect(s.total, 3);
      expect(s.lost, 2);
      expect(s.found, 1);
      expect(s.active, 2);
      expect(s.finished, 1);
    });

    test('dokumen tanpa status dihitung aktif', () {
      final s = ProfileStats.fromData([
        {'reportType': 'hilang'},
      ]);
      expect(s.active, 1);
      expect(s.finished, 0);
    });
  });
}

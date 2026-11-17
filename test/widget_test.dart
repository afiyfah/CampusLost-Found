import 'package:flutter_test/flutter_test.dart';
import 'package:campuslostandfound/services/report_service.dart';

void main() {
  test('Nama barang dapat dibaca', () {
    final data = {
      'itemName': 'Tumbler Hitam',
    };

    expect(
      reportText(data, 'itemName'),
      'Tumbler Hitam',
    );
  });

  test('Field kosong menggunakan nilai default', () {
    expect(reportText({}, 'itemName'), '-');
  });

  test('Tanggal kosong menggunakan nilai default', () {
    expect(reportDate(null), '-');
  });
}

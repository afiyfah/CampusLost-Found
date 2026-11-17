
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static final CollectionReference<Map<String, dynamic>>
      reports =
      FirebaseFirestore.instance.collection('reports');

  // Membaca seluruh laporan
  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchAll() {
    return reports.snapshots();
  }

  // Membaca laporan milik pengguna
  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchMine() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw StateError('Pengguna belum login.');
    }

    return reports
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  // Menambahkan laporan
  static Future<void> create({
    required String reportType,
    required String itemName,
    required String category,
    required String location,
    required DateTime eventDate,
    required String eventTime,
    required String description,
    required String contact,
    required String imageUrl,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw StateError('Pengguna belum login.');
    }

    await reports.add({
      'reportType': reportType,
      'itemName': itemName.trim(),
      'category': category,
      'location': location.trim(),
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'description': description.trim(),
      'contact': contact.trim(),
      'imageUrl': imageUrl.trim(),
      'status': 'aktif',
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Memperbarui status laporan
  static Future<void> finish(String documentId) async {
    await reports.doc(documentId).update({
      'status': 'selesai',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

String reportText(
  Map<String, dynamic> data,
  String key, [
  String fallback = '-',
]) {
  final value = data[key]?.toString() ?? '';
  return value.isEmpty ? fallback : value;
}

String reportDate(dynamic value) {
  if (value is! Timestamp) {
    return '-';
  }

  final date = value.toDate();

  return '${date.day}/${date.month}/${date.year}';
}

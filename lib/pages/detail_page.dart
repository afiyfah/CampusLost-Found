
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/report_card.dart';
import '../widgets/report_contact.dart';

class DetailPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  const DetailPage({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    final data = document.data();
    final imageUrl = reportText(data, 'imageUrl', '');
    final isLost = data['reportType'] == 'hilang';

    return Scaffold(
      backgroundColor: campusBackground,
      appBar: AppBar(
        title: const Text('Detail Barang'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Foto barang
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 230,
              color: const Color(0xFFEDE8FA),
              child: imageUrl.startsWith('https://')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.inventory_2_outlined,
                          size: 86,
                          color: campusPurple,
                        );
                      },
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      size: 86,
                      color: campusPurple,
                    ),
            ),
          ),

          const SizedBox(height: 18),

          // Nama barang
          Text(
            reportText(data, 'itemName'),
            style: const TextStyle(
              fontSize: 24,
              color: campusInk,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          // Jenis dan status laporan
          Text(
            '${isLost ? "Barang Hilang" : "Barang Ditemukan"} · '
            'Status ${reportText(data, "status", "aktif")}',
          ),

          const SizedBox(height: 18),

          // Informasi barang
          _Info(
            'Kategori',
            reportText(data, 'category'),
          ),

          _Info(
            'Lokasi',
            reportText(data, 'location'),
          ),

          _Info(
            'Tanggal',
            reportDate(data['eventDate']),
          ),

          _Info(
            'Waktu',
            reportText(
              data,
              'eventTime',
              'Tidak dicantumkan',
            ),
          ),

          const SizedBox(height: 16),

          const Divider(
            color: Color(0xFFE8E5F2),
          ),

          const SizedBox(height: 12),

          // Deskripsi barang
          const Text(
            'Deskripsi / Ciri-ciri',
            style: TextStyle(
              fontSize: 17,
              color: campusInk,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            reportText(data, 'description'),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Hubungi via WhatsApp
          ReportContact(
            contact: reportText(data, 'contact', ''),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Komponen informasi barang
class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: campusInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/report_card.dart';

class DetailPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>
      document;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 230,
              color: const Color(0xFFEDE8FA),
              child: imageUrl.startsWith('https://')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
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
          Text(
            reportText(data, 'itemName'),
            style: const TextStyle(
              fontSize: 24,
              color: campusInk,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${isLost ? "Barang Hilang" : "Barang Ditemukan"} · '
            'Status ${reportText(data, "status", "aktif")}',
          ),
          const SizedBox(height: 18),
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
          ),
          const SizedBox(height: 20),
          const Text(
            'Kontak Pelapor',
            style: TextStyle(
              fontSize: 17,
              color: campusInk,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reportText(data, 'contact'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hubungi pelapor melalui kanal yang disepakati. '
            'Jangan membagikan data pribadi atau bukti '
            'kepemilikan secara publik.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fitur hubungi pelapor belum diaktifkan. '
                    'Untuk saat ini gunakan kontak '
                    'yang tercantum.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Hubungi Pelapor'),
          ),
        ],
      ),
    );
  }
}

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

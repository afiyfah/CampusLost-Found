
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../pages/detail_page.dart';
import '../services/report_service.dart';

const campusPurple = Color(0xFF5946B2);
const campusInk = Color(0xFF20304D);
const campusBackground = Color(0xFFF8F7FD);

class ReportCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>
      document;

  const ReportCard({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final lost = data['reportType'] == 'hilang';
    final name = reportText(data, 'itemName');
    final category = reportText(
      data,
      'category',
      'Kategori belum diisi',
    );
    final location = reportText(data, 'location');
    final status = reportText(data, 'status', 'aktif');
    final imageUrl = reportText(data, 'imageUrl', '');

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE8E5F2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(
                document: document,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFFF0ECFB),
                  child: imageUrl.startsWith('https://')
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return const Icon(
                              Icons.inventory_2_outlined,
                              color: campusPurple,
                              size: 32,
                            );
                          },
                        )
                      : Icon(
                          lost
                              ? Icons.search
                              : Icons.inventory_2_outlined,
                          color: campusPurple,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: campusInk,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Kategori barang
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Jenis laporan dan lokasi
                    Text(
                      '${lost ? "Hilang" : "Ditemukan"} · $location',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Tanggal laporan
                    Text(
                      reportDate(data['eventDate']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status == 'selesai'
                      ? const Color(0xFFE0F6E9)
                      : const Color(0xFFE9E1FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: campusPurple,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

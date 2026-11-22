import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/report_contact.dart';

class DetailPage extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  const DetailPage({
    super.key,
    required this.document,
  });

  static const Color purple = Color(0xFF5946B2);
  static const Color ink = Color(0xFF20304D);
  static const Color muted = Color(0xFF77718D);
  static const Color lavender = Color(0xFFE9E3FA);
  static const Color background = Color(0xFFF8F7FD);

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final imageUrl = reportText(
      data,
      'imageUrl',
      '',
    );

    final isLost = data['reportType'] == 'hilang';

    final status = reportText(
      data,
      'status',
      'aktif',
    );

    final isFinished = status == 'selesai';

    final itemName = reportText(data, 'itemName');
    final category = reportText(data, 'category');
    final location = reportText(data, 'location');
    final date = reportDate(data['eventDate']);
    final time = reportText(
      data,
      'eventTime',
      'Tidak dicantumkan',
    );
    final description = reportText(
      data,
      'description',
      'Tidak ada deskripsi.',
    );
    final contact = reportText(
      data,
      'contact',
      '',
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Detail Barang',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          final photo = _buildPhoto(
            imageUrl,
            isDesktop,
          );

          final details = _buildDetails(
            itemName: itemName,
            category: category,
            location: location,
            date: date,
            time: time,
            description: description,
            contact: contact,
            isLost: isLost,
            status: status,
            isFinished: isFinished,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: photo,
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: details,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          photo,
                          const SizedBox(height: 18),
                          details,
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  // FOTO BARANG
  Widget _buildPhoto(
    String imageUrl,
    bool isDesktop,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEAE7F3),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: isDesktop ? 360 : 260,
              color: const Color(0xFFF0ECFA),
              child: imageUrl.startsWith('https://')
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: isDesktop ? 360 : 260,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 70,
                            color: purple,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 70,
                        color: purple,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 13),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 16,
                color: muted,
              ),
              SizedBox(width: 7),
              Text(
                'Foto barang yang dilaporkan',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // INFORMASI UTAMA BARANG
  Widget _buildDetails({
    required String itemName,
    required String category,
    required String location,
    required String date,
    required String time,
    required String description,
    required String contact,
    required bool isLost,
    required String status,
    required bool isFinished,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEAE7F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL JENIS DAN STATUS LAPORAN
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _buildBadge(
                isLost
                    ? 'Barang Hilang'
                    : 'Barang Ditemukan',
                isLost
                    ? const Color(0xFFFFF0DB)
                    : lavender,
                isLost
                    ? const Color(0xFFAE741E)
                    : purple,
                isLost
                    ? Icons.search_off_outlined
                    : Icons.inventory_2_outlined,
              ),
              _buildBadge(
                isFinished ? 'Selesai' : 'Aktif',
                isFinished
                    ? const Color(0xFFDCF5EA)
                    : lavender,
                isFinished
                    ? const Color(0xFF18774C)
                    : purple,
                isFinished
                    ? Icons.check_circle_outline
                    : Icons.schedule_outlined,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // NAMA BARANG
          Text(
            itemName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ink,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Informasi laporan barang kampus',
            style: TextStyle(
              fontSize: 13,
              color: muted,
            ),
          ),

          const SizedBox(height: 22),

          const Divider(
            color: Color(0xFFEAE7F3),
          ),

          const SizedBox(height: 12),

          // RINCIAN BARANG
          const Text(
            'Informasi Barang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),

          const SizedBox(height: 17),

          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Kategori',
            value: category,
          ),

          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: location,
          ),

          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal',
            value: date,
          ),

          _InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Waktu',
            value: time.trim().isEmpty
                ? 'Tidak dicantumkan'
                : time,
          ),

          const SizedBox(height: 8),

          const Divider(
            color: Color(0xFFEAE7F3),
          ),

          const SizedBox(height: 18),

          // DESKRIPSI
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: purple,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Deskripsi / Ciri-ciri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: ink,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // TOMBOL WHATSAPP
          ReportContact(
            contact: contact,
          ),

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Hubungi pelapor untuk informasi '
              'lebih lanjut.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LABEL JENIS DAN STATUS
  Widget _buildBadge(
    String label,
    Color backgroundColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// KOMPONEN BARIS INFORMASI
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color purple = Color(0xFF5946B2);
  static const Color ink = Color(0xFF20304D);
  static const Color muted = Color(0xFF77718D);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 17,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0ECFA),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: purple,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';

class HomePage extends StatefulWidget {
  final void Function(int tab) onNavigate;

  const HomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedType = 'hilang';

  static const Color purple = Color(0xFF5946B2);
  static const Color ink = Color(0xFF20304D);
  static const Color muted = Color(0xFF77718D);
  static const Color background = Color(0xFFF8F7FD);
  static const Color lavender = Color(0xFFE9E3FA);

  // Mengambil nama pengguna dari Firebase Authentication
  String get _accountName {
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.trim() ?? '';

    if (displayName.isNotEmpty) {
      return displayName;
    }

    final email = user?.email?.trim() ?? '';

    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Mahasiswa';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: ReportService.watchAll(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            final lost = docs.where(
              (doc) =>
                  doc.data()['reportType'] == 'hilang',
            ).length;

            final found = docs.where(
              (doc) =>
                  doc.data()['reportType'] == 'ditemukan',
            ).length;

            final filtered = docs.where(
              (doc) =>
                  doc.data()['reportType'] == selectedType,
            ).toList();

            // Mengurutkan laporan dari yang terbaru
            filtered.sort((a, b) {
              final aDate =
                  a.data()['createdAt'] as Timestamp?;
              final bDate =
                  b.data()['createdAt'] as Timestamp?;

              if (aDate == null && bDate == null) {
                return 0;
              }

              if (aDate == null) return 1;
              if (bDate == null) return -1;

              return bDate.compareTo(aDate);
            });

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                28,
              ),
              children: [
                // HEADER BERANDA
                _buildHeader(),

                const SizedBox(height: 28),

                // AKSES CEPAT
                const Text(
                  'Akses Cepat',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _quickAction(
                      Icons.campaign_outlined,
                      'Lapor\nHilang',
                      2,
                    ),
                    _quickAction(
                      Icons.inventory_2_outlined,
                      'Lapor\nDitemukan',
                      2,
                    ),
                    _quickAction(
                      Icons.manage_search,
                      'Cari\nBarang',
                      1,
                    ),
                    _quickAction(
                      Icons.assignment_outlined,
                      'Laporan\nSaya',
                      3,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // JUDUL LAPORAN TERBARU
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Laporan Terbaru',
                        style: TextStyle(
                          color: ink,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          widget.onNavigate(1),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // FILTER HILANG DAN DITEMUKAN
                _buildReportTabs(lost, found),

                const SizedBox(height: 16),

                // DATA LAPORAN DARI FIRESTORE
                if (snapshot.hasError)
                  _messageState(
                    Icons.error_outline,
                    'Gagal memuat laporan',
                    'Tidak dapat membaca data dari '
                        'Firestore. Silakan coba kembali.',
                  )
                else if (!snapshot.hasData)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filtered.isEmpty)
                  _messageState(
                    Icons.inventory_2_outlined,
                    'Belum ada laporan',
                    'Belum ada laporan barang '
                        '${selectedType == 'hilang' ? 'hilang' : 'ditemukan'} '
                        'yang tersedia.',
                  )
                else
                  ...filtered.map(
                    (doc) => _reportCard(doc.data()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // HEADER DENGAN NAMA AKUN OTOMATIS
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4939A1),
            Color(0xFF7B65C9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Campus Lost & Found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // NAMA PENGGUNA DINAMIS
          Text(
            'Halo, $_accountName! 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 9),

          const Text(
            'Kehilangan barang atau menemukan '
            'barang di kampus? Yuk, bantu '
            'satu sama lain!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          // PENCARIAN CEPAT
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => widget.onNavigate(1),
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: purple,
                      size: 23,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'Cari barang atau lokasi...',
                        style: TextStyle(
                          color: muted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: muted,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MENU AKSES CEPAT
  Widget _quickAction(
    IconData icon,
    String label,
    int tab,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => widget.onNavigate(tab),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEAE7F3),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: lavender,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: purple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FILTER JENIS LAPORAN
  Widget _buildReportTabs(int lost, int found) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: lavender,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _reportTab(
            'Hilang ($lost)',
            'hilang',
          ),
          _reportTab(
            'Ditemukan ($found)',
            'ditemukan',
          ),
        ],
      ),
    );
  }

  Widget _reportTab(
    String label,
    String type,
  ) {
    final active = selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedType = type;
          });
        },
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: active
                ? purple
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // KARTU BARANG DARI FIRESTORE
  Widget _reportCard(Map<String, dynamic> data) {
    final imageUrl = reportText(
      data,
      'imageUrl',
      '',
    );

    final status = reportText(
      data,
      'status',
      'aktif',
    );

    final isFinished = status == 'selesai';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAE7F3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO BARANG
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 76,
              height: 86,
              color: const Color(0xFFF0ECFA),
              child: imageUrl.startsWith('https://')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.inventory_2_outlined,
                          color: purple,
                          size: 30,
                        );
                      },
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      color: purple,
                      size: 30,
                    ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  reportText(data, 'itemName'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  reportText(data, 'category'),
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 9),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: muted,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        reportText(data, 'location'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: muted,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        reportDate(data['eventDate']),
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // STATUS LAPORAN
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isFinished
                  ? const Color(0xFFDCF5EA)
                  : lavender,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isFinished
                    ? const Color(0xFF18774C)
                    : purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAMPILAN KETIKA DATA KOSONG ATAU ERROR
  Widget _messageState(
    IconData icon,
    String title,
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: const BoxDecoration(
              color: lavender,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: purple,
              size: 32,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: ink,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              height: 1.5,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

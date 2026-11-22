import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/report_card.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  String filter = 'semua';

  static const Color primary = Color(0xFF5946B2);
  static const Color dark = Color(0xFF20304D);
  static const Color muted = Color(0xFF77718D);

  Widget _statCard(
    String label,
    int value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE9E3FA),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 22),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final isAll = filter == 'semua';

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 55,
        horizontal: 18,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Color(0xFFE9E3FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 42,
              color: primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isAll
                ? 'Belum ada laporan'
                : 'Tidak ada laporan ${filter == 'hilang' ? 'hilang' : 'ditemukan'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAll
                ? 'Laporan yang kamu buat akan tampil '
                    'di halaman ini.'
                : 'Belum ada laporan pada kategori '
                    'yang dipilih.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishReport(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Selesaikan laporan?'),
          content: const Text(
            'Status laporan akan berubah menjadi selesai.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, selesai'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await ReportService.finish(documentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Laporan berhasil ditandai selesai.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak dapat mengubah status: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: campusBackground,
      appBar: AppBar(
        title: const Text(
          'Laporan Saya',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark,
          ),
        ),
        backgroundColor: campusBackground,
        elevation: 0,
      ),
      body: uid == null
          ? const Center(
              child: Text('Sesi pengguna tidak tersedia.'),
            )
          : StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
              stream: ReportService.watchMine(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Gagal membaca laporan: '
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final allDocs = snapshot.data!.docs;

                final activeCount = allDocs.where(
                  (d) => d.data()['status'] == 'aktif',
                ).length;

                final completedCount = allDocs.where(
                  (d) => d.data()['status'] == 'selesai',
                ).length;

                final docs = allDocs.where((d) {
                  return filter == 'semua' ||
                      d.data()['reportType'] == filter;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kelola Laporanmu',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Pantau barang yang kamu '
                                'laporkan di sini.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E3FA),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    Row(
                      children: [
                        _statCard(
                          'Total',
                          allDocs.length,
                          Icons.folder_outlined,
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          'Aktif',
                          activeCount,
                          Icons.schedule_outlined,
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          'Selesai',
                          completedCount,
                          Icons.check_circle_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Daftar Laporan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'semua',
                            label: Text('Semua'),
                          ),
                          ButtonSegment(
                            value: 'hilang',
                            label: Text('Hilang'),
                          ),
                          ButtonSegment(
                            value: 'ditemukan',
                            label: Text('Ditemukan'),
                          ),
                        ],
                        selected: {filter},
                        onSelectionChanged: (selected) {
                          setState(() {
                            filter = selected.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (docs.isEmpty) _emptyState(),

                    for (final doc in docs) ...[
                      ReportCard(document: doc),

                      if (doc.data()['status'] == 'aktif')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                _finishReport(doc.id),
                            icon: const Icon(
                              Icons.check_circle_outline,
                            ),
                            label: const Text(
                              'Tandai selesai',
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

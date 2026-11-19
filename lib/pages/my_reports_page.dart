
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/report_card.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() =>
      _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  String filter = 'semua';

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: campusBackground,
      appBar: AppBar(
        title: const Text('Laporan Saya'),
      ),
      body: uid == null
          ? const Center(
              child: Text(
                'Sesi pengguna tidak tersedia.',
              ),
            )
          : StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
              stream: ReportService.watchMine(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal membaca riwayat: '
                      '${snapshot.error}',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data!.docs.where((d) {
                  return filter == 'semua' ||
                      d.data()['reportType'] == filter;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SegmentedButton<String>(
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
                      onSelectionChanged: (s) {
                        setState(() => filter = s.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (docs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          'Belum ada laporan dari sesi ini.\n'
                          'Data contoh Firebase menggunakan '
                          'user_demo dan tidak muncul '
                          'di Laporan Saya.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final doc in docs) ...[
                      ReportCard(document: doc),
                      if (doc.data()['status'] == 'aktif')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              final confirmed =
                                  await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Selesaikan laporan?',
                                    ),
                                    content: const Text(
                                      'Status laporan akan '
                                      'menjadi selesai.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            ctx,
                                            false,
                                          );
                                        },
                                        child: const Text('Batal'),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            ctx,
                                            true,
                                          );
                                        },
                                        child: const Text(
                                          'Ya, selesai',
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed != true) {
                                return;
                              }

                              try {
                                await ReportService.finish(
                                  doc.id,
                                );
                              } catch (e) {
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Tidak dapat mengubah '
                                      'status: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                            ),
                            label: const Text(
                              'Tandai selesai',
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

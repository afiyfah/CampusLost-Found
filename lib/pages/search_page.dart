
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/report_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  String category = 'Semua';
  String reportType = 'semua';
  String status = 'semua';

  final categories = const [
    'Semua',
    'Elektronik',
    'Dokumen',
    'Aksesoris',
    'Perlengkapan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: campusBackground,
      appBar: AppBar(
        title: const Text('Pencarian & Filter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16, 14, 16, 7,
            ),
            child: TextField(
              onChanged: (s) {
                setState(() {
                  query = s.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama barang atau lokasi...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 0, 4),
              child: Text(
                'Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              children: categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: category == c,
                    onSelected: (_) {
                      setState(() => category = c);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: reportType,
                    decoration: const InputDecoration(
                      labelText: 'Jenis laporan',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'semua',
                        child: Text('Semua'),
                      ),
                      DropdownMenuItem(
                        value: 'hilang',
                        child: Text('Hilang'),
                      ),
                      DropdownMenuItem(
                        value: 'ditemukan',
                        child: Text('Ditemukan'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        reportType = v ?? 'semua';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'semua',
                        child: Text('Semua'),
                      ),
                      DropdownMenuItem(
                        value: 'aktif',
                        child: Text('Aktif'),
                      ),
                      DropdownMenuItem(
                        value: 'selesai',
                        child: Text('Selesai'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        status = v ?? 'semua';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: ReportService.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal membaca data: ${snapshot.error}',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final filtered =
                    snapshot.data!.docs.where((doc) {
                  final d = doc.data();

                  final name =
                      reportText(d, 'itemName', '')
                          .toLowerCase();
                  final loc =
                      reportText(d, 'location', '')
                          .toLowerCase();
                  final cat =
                      reportText(d, 'category', '');
                  final typ =
                      reportText(d, 'reportType', '');
                  final stat =
                      reportText(d, 'status', '');

                  return (name.contains(query) ||
                          loc.contains(query)) &&
                      (category == 'Semua' ||
                          cat == category) &&
                      (reportType == 'semua' ||
                          typ == reportType) &&
                      (status == 'semua' ||
                          stat == status);
                }).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    16, 8, 16, 16,
                  ),
                  children: [
                    Text(
                      'Hasil Pencarian (${filtered.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: campusInk,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Tidak ada barang yang sesuai.',
                        ),
                      ),
                    ...filtered.map(
                      (d) => ReportCard(document: d),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

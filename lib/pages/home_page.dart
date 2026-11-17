import 'package:cloud_firestore/cloud_firestore.dart';
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

  static const purple = Color(0xFF5946B2);
  static const ink = Color(0xFF20304D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // HEADER BERANDA
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4939A1),
                        Color(0xFF8064CF),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Campus Lost & Found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Halo, Mahasiswa! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Bantu sesama civitas kampus '
                        'menemukan barang yang hilang '
                        'atau ditemukan.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 18),

                      InkWell(
                        onTap: () =>
                            widget.onNavigate(1),
                        child: Container(
                          padding:
                              const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: purple,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Cari barang (tumbler, dompet, dll)',
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // MENU AKSES CEPAT
                Row(
                  children: [
                    quickAction(
                      Icons.campaign_outlined,
                      'Lapor\nHilang',
                      2,
                    ),
                    quickAction(
                      Icons.inventory_2_outlined,
                      'Lapor\nDitemukan',
                      2,
                    ),
                    quickAction(
                      Icons.search,
                      'Pencarian\n& Filter',
                      1,
                    ),
                    quickAction(
                      Icons.assignment_outlined,
                      'Laporan\nSaya',
                      3,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // TAB HILANG DAN DITEMUKAN
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEAF4),
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      reportTab(
                        'Hilang ($lost)',
                        'hilang',
                      ),
                      reportTab(
                        'Ditemukan ($found)',
                        'ditemukan',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // PENAMPILAN DATA FIRESTORE
                if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Gagal membaca data: '
                      '${snapshot.error}',
                    ),
                  )
                else if (!snapshot.hasData)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('Belum ada laporan.'),
                    ),
                  )
                else
                  ...filtered.map((doc) {
                    final data = doc.data();

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding:
                              const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE8FA),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: purple,
                          ),
                        ),
                        title: Text(
                          reportText(data, 'itemName'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ink,
                          ),
                        ),
                        subtitle: Text(
                          '${reportText(data, "category")}\n'
                          '${reportText(data, "location")}\n'
                          '${reportDate(data["eventDate"])}',
                        ),
                        isThreeLine: true,
                        trailing: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E1FF),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            reportText(data, 'status'),
                            style: const TextStyle(
                              color: purple,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  // Komponen tombol akses cepat
  Widget quickAction(
    IconData icon,
    String label,
    int tab,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3,
        ),
        child: InkWell(
          onTap: () => widget.onNavigate(tab),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 94,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEAFA),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: purple,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Komponen tab laporan
  Widget reportTab(String label, String type) {
    final active = selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: active
                ? purple
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : ink,
            ),
          ),
        ),
      ),
    );
  }
}

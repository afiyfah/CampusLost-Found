import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/report_service.dart';
import '../widgets/report_card.dart';

/// Ringkasan laporan milik pengguna yang sedang login.
/// Dipisah dari widget agar mudah diuji tanpa Firebase.
class ProfileStats {
  final int total;
  final int lost;
  final int found;
  final int active;
  final int finished;

  const ProfileStats({
    this.total = 0,
    this.lost = 0,
    this.found = 0,
    this.active = 0,
    this.finished = 0,
  });

  factory ProfileStats.fromData(
    Iterable<Map<String, dynamic>> items,
  ) {
    int total = 0, lost = 0, found = 0, active = 0, finished = 0;

    for (final data in items) {
      total++;
      if (data['reportType'] == 'hilang') lost++;
      if (data['reportType'] == 'ditemukan') found++;
      // Dokumen tanpa field status dianggap 'aktif'
      // (sama seperti ReportCard).
      final status = data['status'] ?? 'aktif';
      if (status == 'selesai') {
        finished++;
      } else {
        active++;
      }
    }

    return ProfileStats(
      total: total,
      lost: lost,
      found: found,
      active: active,
      finished: finished,
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: campusBackground,
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Header(user: user),
          const SizedBox(height: 22),
          const _SectionTitle('Ringkasan Laporan Saya'),
          const SizedBox(height: 10),
          if (user == null)
            const _Note(
              'Sesi pengguna belum tersedia, '
              'ringkasan laporan tidak dapat ditampilkan.',
            )
          else
            const _StatsSection(),
          const SizedBox(height: 22),
          const _SectionTitle('ID Sesi Firebase'),
          const SizedBox(height: 8),
          _UidBox(uid: user?.uid),
          const SizedBox(height: 22),
          const _Note(
            'Profil ini masih tahap awal. Login mahasiswa dan '
            'verifikasi identitas belum diterapkan. Jangan '
            'gunakan akun anonim sebagai bukti kepemilikan '
            'barang.',
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final User? user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final anonymous = user?.isAnonymous == true;

    return Column(
      children: [
        const CircleAvatar(
          radius: 38,
          backgroundColor: Color(0xFFE9E1FF),
          child: Icon(
            Icons.person_outline,
            size: 42,
            color: campusPurple,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Pengguna Campus Lost & Found',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: campusInk,
          ),
        ),
        const SizedBox(height: 8),
        Chip(
          avatar: Icon(
            anonymous
                ? Icons.visibility_off_outlined
                : Icons.verified_user_outlined,
            size: 18,
            color: campusPurple,
          ),
          label: Text(
            user == null
                ? 'Belum masuk'
                : anonymous
                    ? 'Mode tamu (anonim)'
                    : 'Akun pengguna',
          ),
          backgroundColor: const Color(0xFFE9E1FF),
          side: BorderSide.none,
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ReportService.watchMine(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Note(
            'Gagal membaca ringkasan: ${snapshot.error}',
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final s = ProfileStats.fromData(
          snapshot.data!.docs.map((d) => d.data()),
        );

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.9,
          children: [
            _StatTile('Total laporan', s.total, Icons.inventory_2_outlined),
            _StatTile('Barang hilang', s.lost, Icons.search_off_outlined),
            _StatTile('Barang ditemukan', s.found, Icons.task_alt_outlined),
            _StatTile('Masih aktif', s.active, Icons.hourglass_bottom),
            _StatTile('Selesai', s.finished, Icons.check_circle_outline),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _StatTile(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E5F2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: campusPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: campusInk,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
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

class _UidBox extends StatelessWidget {
  final String? uid;
  const _UidBox({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E5F2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              uid ?? 'Belum masuk',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          if (uid != null)
            IconButton(
              tooltip: 'Salin ID',
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: uid!));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID sesi disalin')),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: campusInk,
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black54),
    );
  }
}

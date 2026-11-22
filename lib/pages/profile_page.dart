import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
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
    // userChanges() ikut berubah saat nama akun selesai disimpan.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

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
              const _SectionTitle('ID Akun'),
              const SizedBox(height: 8),
              _UidBox(uid: user?.uid),
              const SizedBox(height: 22),
              _AuthActions(user: user),
            ],
          ),
        );
      },
    );
  }
}

String profileDisplayName(User? user) {
  if (user == null) return 'Belum masuk';
  if (user.isAnonymous) return 'Tamu';

  final name = user.displayName?.trim() ?? '';
  if (name.isNotEmpty) return name;

  final email = user.email ?? '';
  return email.contains('@') ? email.split('@').first : 'Pengguna';
}

class _Header extends StatelessWidget {
  final User? user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final anonymous = user?.isAnonymous == true;
    final name = profileDisplayName(user);
    final email = user?.email;

    return Column(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: const Color(0xFFE9E1FF),
          child: (user == null || anonymous)
              ? const Icon(
                  Icons.person_outline,
                  size: 42,
                  color: campusPurple,
                )
              : Text(
                  name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: campusPurple,
                  ),
                ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: campusInk,
          ),
        ),
        if (email != null && email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 10),
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
                    : 'Akun terdaftar',
          ),
          backgroundColor: const Color(0xFFE9E1FF),
          side: BorderSide.none,
        ),
      ],
    );
  }
}

class _AuthActions extends StatelessWidget {
  final User? user;
  const _AuthActions({required this.user});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu akan kembali ke halaman Masuk.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final anonymous = user?.isAnonymous == true;

    if (user == null) return const SizedBox.shrink();

    if (anonymous) {
      return Column(
        children: [
          const _Note(
            'Kamu masuk sebagai tamu. Laporan yang dibuat sebagai '
            'tamu tidak ikut terbawa ke akun terdaftar.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => AuthService.signOut(),
            icon: const Icon(Icons.login),
            label: const Text('Masuk / Daftar Akun'),
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _logout(context),
      icon: const Icon(Icons.logout),
      label: const Text('Keluar'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade700,
        side: BorderSide(color: Colors.red.shade200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
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

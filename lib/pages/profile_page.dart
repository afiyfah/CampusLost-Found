
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/report_service.dart';

// WARNA TEMA
const Color profilePurple = Color(0xFF5946B2);
const Color profileInk = Color(0xFF20304D);
const Color profileMuted = Color(0xFF77718D);
const Color profileBackground = Color(0xFFF8F7FD);
const Color profileLavender = Color(0xFFE9E3FA);

// LOGIKA STATISTIK TETAP DIPERTAHANKAN
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
    int total = 0;
    int lost = 0;
    int found = 0;
    int active = 0;
    int finished = 0;

    for (final data in items) {
      total++;

      if (data['reportType'] == 'hilang') lost++;
      if (data['reportType'] == 'ditemukan') found++;

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

// NAMA PENGGUNA
String profileDisplayName(User? user) {
  if (user == null) return 'Belum masuk';
  if (user.isAnonymous) return 'Tamu';

  final name = user.displayName?.trim() ?? '';
  if (name.isNotEmpty) return name;

  final email = user.email ?? '';
  return email.contains('@')
      ? email.split('@').first
      : 'Pengguna';
}

// HALAMAN PROFIL
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          backgroundColor: profileBackground,
          appBar: AppBar(
            title: const Text(
              'Profil Saya',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: profileInk,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Akun',
                      style: TextStyle(
                        color: profileInk,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Kelola informasi akun dan pantau '
                      'aktivitas laporanmu.',
                      style: TextStyle(
                        color: profileMuted,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _ProfileHeader(user: user),

                    const SizedBox(height: 28),

                    const _SectionTitle(
                      'Ringkasan Aktivitas',
                    ),
                    const SizedBox(height: 12),

                    if (user == null)
                      const _Note(
                        'Sesi pengguna belum tersedia.',
                      )
                    else
                      const _StatsSection(),

                    const SizedBox(height: 28),

                    const _SectionTitle(
                      'Detail Akun',
                    ),
                    const SizedBox(height: 12),

                    _AccountCard(user: user),

                    const SizedBox(height: 22),

                    _AuthActions(user: user),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// KARTU IDENTITAS PENGGUNA
class _ProfileHeader extends StatelessWidget {
  final User? user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final anonymous = user?.isAnonymous == true;
    final name = profileDisplayName(user);
    final email = user?.email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEAE7F3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: profileLavender,
            child: user == null || anonymous
                ? const Icon(
                    Icons.person_outline,
                    size: 36,
                    color: profilePurple,
                  )
                : Text(
                    name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                      color: profilePurple,
                    ),
                  ),
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: profileInk,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email != null && email.isNotEmpty
                      ? email
                      : 'Tidak ada email terdaftar',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: profileMuted,
                  ),
                ),

                const SizedBox(height: 11),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: profileLavender,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        anonymous
                            ? Icons.visibility_outlined
                            : Icons.verified_user_outlined,
                        size: 15,
                        color: profilePurple,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          user == null
                              ? 'Belum masuk'
                              : anonymous
                                  ? 'Mode tamu'
                                  : 'Akun terdaftar',
                          style: const TextStyle(
                            fontSize: 11,
                            color: profilePurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

// RINGKASAN LAPORAN DARI FIRESTORE
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
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
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final stats = ProfileStats.fromData(
          snapshot.data!.docs.map(
            (document) => document.data(),
          ),
        );

        final items = [
          _StatItem(
            'Total Laporan',
            stats.total,
            Icons.inventory_2_outlined,
            profilePurple,
          ),
          _StatItem(
            'Barang Hilang',
            stats.lost,
            Icons.search_off_outlined,
            const Color(0xFFD48A29),
          ),
          _StatItem(
            'Ditemukan',
            stats.found,
            Icons.inventory_outlined,
            const Color(0xFF3F9D79),
          ),
          _StatItem(
            'Masih Aktif',
            stats.active,
            Icons.schedule_outlined,
            profilePurple,
          ),
          _StatItem(
            'Selesai',
            stats.finished,
            Icons.check_circle_outline,
            const Color(0xFF3F9D79),
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns = width >= 700
                ? 3
                : width >= 380
                    ? 2
                    : 1;

            const spacing = 12.0;

            final cardWidth =
                (width - spacing * (columns - 1)) /
                    columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: items.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: _StatCard(item: item),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

// DATA KARTU STATISTIK
class _StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatItem(
    this.label,
    this.value,
    this.icon,
    this.color,
  );
}

// KARTU STATISTIK RINGKAS
class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEAE7F3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              item.icon,
              size: 22,
              color: item.color,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.value}',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: profileInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: profileMuted,
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

// DETAIL IDENTITAS AKUN
class _AccountCard extends StatelessWidget {
  final User? user;

  const _AccountCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAE7F3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: profilePurple,
              ),
              SizedBox(width: 9),
              Text(
                'Identitas Pengguna',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: profileInk,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          const Divider(
            color: Color(0xFFEAE7F3),
          ),

          const SizedBox(height: 14),

          const Text(
            'ID Akun Firebase',
            style: TextStyle(
              fontSize: 12,
              color: profileMuted,
            ),
          ),

          const SizedBox(height: 9),

          _UidBox(uid: user?.uid),
        ],
      ),
    );
  }
}

// SALIN ID AKUN
class _UidBox extends StatelessWidget {
  final String? uid;

  const _UidBox({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: profileBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEAE7F3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              uid ?? 'Belum masuk',
              style: const TextStyle(
                fontSize: 12,
                color: profileInk,
              ),
            ),
          ),

          if (uid != null)
            IconButton(
              tooltip: 'Salin ID',
              icon: const Icon(
                Icons.copy_outlined,
                size: 19,
                color: profilePurple,
              ),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: uid!),
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'ID akun berhasil disalin.',
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// AKSI LOGIN DAN LOGOUT
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
    if (user == null) {
      return const SizedBox.shrink();
    }

    if (user!.isAnonymous) {
      return Column(
        children: [
          const _Note(
            'Kamu masuk sebagai tamu. Laporan yang '
            'dibuat sebagai tamu tidak ikut '
            'terbawa ke akun terdaftar.',
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => AuthService.signOut(),
              icon: const Icon(Icons.login),
              label: const Text(
                'Masuk / Daftar Akun',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: profilePurple,
                padding: const EdgeInsets.all(15),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout),
        label: const Text('Keluar dari Akun'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFC74755),
          side: const BorderSide(
            color: Color(0xFFF0C5CB),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}

// JUDUL BAGIAN
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: profileInk,
      ),
    );
  }
}

// PESAN INFORMASI
class _Note extends StatelessWidget {
  final String text;

  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 13,
        color: profileMuted,
        height: 1.5,
      ),
    );
  }
}

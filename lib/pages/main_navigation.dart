
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'search_page.dart';
import 'my_reports_page.dart';
import 'report_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Indeks halaman utama:
  // 0 = Beranda
  // 1 = Pencarian
  // 2 = Lapor
  // 3 = Laporan Saya
  // 4 = Profil
  int selected = 0;

  void changePage(int index) {
    final user = FirebaseAuth.instance.currentUser;

    final isGuest = user == null || user.isAnonymous;

    // Tamu tidak bisa membuka Lapor dan Laporan Saya.
    if (isGuest && (index == 2 || index == 3)) {
      setState(() {
        selected = 4;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan masuk atau daftar akun '
              'untuk membuat dan mengelola laporan.',
            ),
            duration: Duration(seconds: 3),
          ),
        );

      return;
    }

    setState(() {
      selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        final isGuest = user == null || user.isAnonymous;

        // Daftar halaman untuk tamu hanya berisi:
        // Beranda, Pencarian, dan Profil.
        //
        // Akun terdaftar mendapatkan semua halaman.
        final pages = isGuest
            ? <Widget>[
                HomePage(onNavigate: changePage),
                const SearchPage(),
                const ProfilePage(),
              ]
            : <Widget>[
                HomePage(onNavigate: changePage),
                const SearchPage(),
                const ReportPage(),
                const MyReportsPage(),
                const ProfilePage(),
              ];

        // Indeks tab untuk mode tamu berbeda
        // karena hanya memiliki tiga halaman.
        final selectedIndex = isGuest
            ? selected == 4
                ? 2
                : selected == 1
                    ? 1
                    : 0
            : selected;

        return Scaffold(
          body: IndexedStack(
            index: selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            height: 75,
            selectedIndex: selectedIndex,

            // Tab tamu: 0, 1, 2.
            // Tab akun: 0, 1, 2, 3, 4.
            onDestinationSelected: (index) {
              if (isGuest) {
                if (index == 0) {
                  changePage(0);
                } else if (index == 1) {
                  changePage(1);
                } else {
                  changePage(4);
                }
              } else {
                changePage(index);
              }
            },

            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFE9E1FF),

            destinations: isGuest
                ? const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Beranda',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search),
                      label: 'Pencarian',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ]
                : const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Beranda',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search),
                      label: 'Pencarian',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF5946B2),
                      ),
                      selectedIcon: Icon(
                        Icons.add_circle,
                        color: Color(0xFF5946B2),
                      ),
                      label: 'Lapor',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.assignment_outlined),
                      label: 'Laporan Saya',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ],
          ),
        );
      },
    );
  }
}

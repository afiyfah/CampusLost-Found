
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
  int selected = 0;

  void changePage(int index) {
    setState(() {
      selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigate: changePage),
      const SearchPage(),
      const ReportPage(),
      const MyReportsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selected,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 75,
        selectedIndex: selected,
        onDestinationSelected: changePage,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE9E1FF),
        destinations: const [
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
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

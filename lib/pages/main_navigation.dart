
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'my_reports_page.dart';

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
      const _TemporaryPage(
        title: 'Lapor Barang',
        icon: Icons.add_circle_outline,
      ),
      const MyReportsPage(),
      const _TemporaryPage(
        title: 'Profil',
        icon: Icons.person_outline,
      ),
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

// Halaman sementara untuk fitur dalam pengembangan
class _TemporaryPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _TemporaryPage({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 65,
              color: const Color(0xFF5946B2),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Halaman sedang dalam pengembangan.',
            ),
          ],
        ),
      ),
    );
  }
}

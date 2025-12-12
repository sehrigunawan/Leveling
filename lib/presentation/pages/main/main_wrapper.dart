import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'dashboard_page.dart';
import 'goals_page.dart';
import 'challenges_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // --- URUTAN HALAMAN HARUS SESUAI DENGAN ICON DI BAWAH ---
  final List<Widget> _pages = [
    const DashboardPage(),      // Index 0
    const GoalsPage(),          // Index 1
    const ChallengesPage(),     // Index 2
    const StatisticsPage(),     // Index 3 
    const ProfilePage(),        // Index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan halaman sesuai index yang dipilih
      body: _pages[_selectedIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Agar semua icon & label muncul
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.brandPurple,
          unselectedItemColor: AppColors.textMuted,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), // Icon Target/Goals
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt), // Icon Challenge
              label: 'Challenge',
            ),
            // --- INI ITEM STATISTIC (Index 3) ---
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), 
              label: 'Statistik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
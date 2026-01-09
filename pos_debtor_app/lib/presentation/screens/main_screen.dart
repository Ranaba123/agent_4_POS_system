import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard/dashboard_screen.dart';
import 'debtors/debtor_list_screen.dart';
import 'debtors/add_debtor_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DebtorListScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];
  
  final List<String> _titles = [
    "Dashboard",
    "Debtors",
    "Reports",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Debtors',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up), 
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 // Show FAB only on Debtor List tab
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to Add Debtor
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddDebtorScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Debtor"),
            )
          : null,
    );
  }
}

// Temporary placeholders until we create the files
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Reports Coming Soon"));
}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Settings Coming Soon"));
}

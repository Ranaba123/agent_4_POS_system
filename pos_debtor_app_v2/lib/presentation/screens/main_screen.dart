import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard/dashboard_screen.dart';
import 'debtors/debtor_list_screen.dart';
import 'debtors/add_debtor_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';
import 'package:provider/provider.dart';
import '../../core/app_localization.dart';
import '../viewmodels/navigation_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // int _currentIndex = 0; // Managed by Provider now

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DebtorListScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocalizationProvider>(context).current;
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navigationProvider.currentIndex;

    final List<String> titles = [
      loc.translate('dashboard'),
      loc.translate('debtors'),
      loc.translate('topDebtors'),
      loc.translate('settings'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex],
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          Provider.of<NavigationProvider>(context, listen: false)
              .setIndex(index);
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
      floatingActionButton: currentIndex ==
              1 // Show FAB only on Debtor List tab
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

// Placeholders removed as they are now implemented in their respective files.

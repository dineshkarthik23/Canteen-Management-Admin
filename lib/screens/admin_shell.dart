import 'package:flutter/material.dart';

import 'package:clg_admin/screens/categories_screen.dart';
import 'package:clg_admin/screens/dashboard_screen.dart';
import 'package:clg_admin/screens/manage_items_screen.dart';
import 'package:clg_admin/screens/settings_screen.dart';
import 'package:clg_admin/services/app_state.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
    required this.appState,
    required this.onLogout,
    required this.themeMode,
    required this.onThemeToggle,
  });

  final AppState appState;
  final VoidCallback onLogout;
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeToggle;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(appState: widget.appState),
      ManageItemsScreen(appState: widget.appState),
      CategoriesScreen(appState: widget.appState),
      SettingsScreen(
        appState: widget.appState,
        onLogout: widget.onLogout,
        themeMode: widget.themeMode,
        onThemeToggle: widget.onThemeToggle,
      ),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F8FF), Color(0xFFEAF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        height: 74,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.fastfood_outlined),
            selectedIcon: Icon(Icons.fastfood),
            label: 'Items',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

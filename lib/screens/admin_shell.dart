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

  static const _destinations = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.grid_view_rounded,
      selectedIcon: Icons.grid_view_rounded,
    ),
    _NavItem(
      label: 'Items',
      icon: Icons.fastfood_outlined,
      selectedIcon: Icons.fastfood_rounded,
    ),
    _NavItem(
      label: 'Categories',
      icon: Icons.category_outlined,
      selectedIcon: Icons.category_rounded,
    ),
    _NavItem(
      label: 'Settings',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildNavBar(isDark),
    );
  }

  Widget _buildNavBar(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1830) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF4F46E5).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF2D2B4E)
                : const Color(0xFF4F46E5).withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: List.generate(_destinations.length, (index) {
              final selected = _currentIndex == index;
              final item = _destinations[index];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selected ? item.selectedIcon : item.icon,
                            key: ValueKey(selected),
                            size: 24,
                            color: selected
                                ? cs.primary
                                : (isDark
                                    ? Colors.white38
                                    : const Color(0xFF94A3B8)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            color: selected
                                ? cs.primary
                                : (isDark
                                    ? Colors.white38
                                    : const Color(0xFF94A3B8)),
                            fontFamily: 'Nunito',
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
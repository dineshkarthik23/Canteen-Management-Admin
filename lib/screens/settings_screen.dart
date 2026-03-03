import 'package:flutter/material.dart';

import 'package:clg_admin/services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
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

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
  ) async {
    final value = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return value ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Canteen Administrator',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'admin@collegecanteen.local',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile.adaptive(
                  value: themeMode == ThemeMode.dark,
                  onChanged: onThemeToggle,
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark themes'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('Current Analytics'),
                  subtitle: Text(
                    'Items: ${appState.totalItems} | Categories: ${appState.totalCategories} | Revenue est: Rs. ${appState.totalRevenueEstimate.toStringAsFixed(2)}',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.restore_outlined),
                  title: const Text('Reset Data'),
                  subtitle: const Text(
                    'Restore default categories and sample items',
                  ),
                  onTap: () async {
                    final confirmed = await _confirm(
                      context,
                      'Reset Data',
                      'This will remove current changes and restore defaults. Continue?',
                    );
                    if (!confirmed) {
                      return;
                    }
                    appState.resetData();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data reset to default values.'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text('Sign out from admin session'),
                  onTap: () async {
                    final confirmed = await _confirm(
                      context,
                      'Logout',
                      'Are you sure you want to logout?',
                    );
                    if (!confirmed || !context.mounted) {
                      return;
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onLogout();
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Security note: this demo uses locally defined admin credentials.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

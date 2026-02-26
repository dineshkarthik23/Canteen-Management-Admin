import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clg_admin/screens/admin_shell.dart';
import 'package:clg_admin/screens/login_screen.dart';
import 'package:clg_admin/screens/splash_screen.dart';
import 'package:clg_admin/services/app_state.dart';
import 'package:clg_admin/services/auth_service.dart';

void main() {
  runApp(const CanteenAdminApp());
}

class CanteenAdminApp extends StatefulWidget {
  const CanteenAdminApp({super.key});

  @override
  State<CanteenAdminApp> createState() => _CanteenAdminAppState();
}

class _CanteenAdminAppState extends State<CanteenAdminApp> {
  final AppState _appState = AppState();
  final AuthService _authService = AuthService();

  bool _showSplash = true;
  bool _isLoggedIn = false;
  ThemeMode _themeMode = ThemeMode.light;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
      _showSplash = false;
    });
  }

  void _onThemeToggle(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bluePrimary = Color(0xFF0D47A1);

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: bluePrimary),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: bluePrimary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 20, 94, 212),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return MaterialApp(
      title: 'Canteen Admin Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: _showSplash
          ? const SplashScreen()
          : _isLoggedIn
          ? AdminShell(
              appState: _appState,
              themeMode: _themeMode,
              onThemeToggle: _onThemeToggle,
              onLogout: _onLogout,
            )
          : LoginScreen(
              authService: _authService,
              onLoginSuccess: _onLoginSuccess,
            ),
    );
  }
}

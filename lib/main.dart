import 'package:flutter/material.dart';
import 'package:clg_admin/screens/admin_shell.dart';
import 'package:clg_admin/screens/login_screen.dart';
import 'package:clg_admin/screens/splash_screen.dart';
import 'package:clg_admin/services/app_state.dart';
import 'package:clg_admin/services/auth_service.dart';
import 'package:clg_admin/services/cache_service.dart';

void main() {
  runApp(const CanteenAdminApp());
}

class CanteenAdminApp extends StatefulWidget {
  const CanteenAdminApp({super.key});

  @override
  State<CanteenAdminApp> createState() => _CanteenAdminAppState();
}

class _CanteenAdminAppState extends State<CanteenAdminApp> {
  final AuthService _authService = AuthService();
  final CacheService _cacheService = CacheService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppState _appState;

  bool _showSplash = true;
  bool _isLoggedIn = false;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _appState.setPersistStateCallback(_cacheService.saveAppState);
    _bootstrapFromCache();
  }

  Future<void> _bootstrapFromCache() async {
    final started = DateTime.now();
    final cachedState = await _cacheService.loadAppState();
    if (cachedState != null) {
      final restored = _appState.hydrateFromJsonMap(cachedState);
      if (!restored) {
        _appState.resetData(notify: false);
      }
    }

    final cachedTheme = await _cacheService.getThemeMode();
    final cachedLogin = await _cacheService.isLoggedIn();

    final elapsed = DateTime.now().difference(started);
    const splashDuration = Duration(seconds: 2);
    if (elapsed < splashDuration) {
      await Future<void>.delayed(splashDuration - elapsed);
    }

    _safeSetState(() {
      _themeMode = cachedTheme;
      _isLoggedIn = cachedLogin;
      _showSplash = false;
    });
  }

  void _onLoginSuccess() {
    _cacheService.setLoggedIn(true);
    _safeSetState(() {
      _isLoggedIn = true;
    });
  }

  void _onLogout() {
    // Close transient routes (dialogs/bottom sheets) before swapping the root.
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _cacheService.setLoggedIn(false);
    _safeSetState(() {
      _isLoggedIn = false;
      _showSplash = false;
    });
  }

  void _onThemeToggle(bool enabled) {
    _cacheService.setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
    _safeSetState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(fn);
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
      navigatorKey: _navigatorKey,
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

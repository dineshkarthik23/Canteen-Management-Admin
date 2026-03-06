import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rich indigo-to-violet palette with warm amber accent
    const primaryIndigo = Color(0xFF3730A3);
    const primaryDeep = Color(0xFF4F46E5);
    const accentAmber = Color(0xFFF59E0B);
    const surfaceLight = Color(0xFFF8F7FF);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDeep,
        primary: primaryDeep,
        secondary: accentAmber,
        tertiary: const Color(0xFF06B6D4),
        surface: surfaceLight,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: primaryDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          fontFamily: 'Nunito',
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: primaryDeep.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F2FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryDeep.withValues(alpha: 0.15), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryDeep, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        labelStyle: TextStyle(color: primaryDeep.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
        prefixIconColor: primaryDeep,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 72,
        indicatorColor: primaryDeep.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 11,
            color: selected ? primaryDeep : const Color(0xFF94A3B8),
            fontFamily: 'Nunito',
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primaryDeep : const Color(0xFF94A3B8),
            size: 24,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryDeep,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            fontFamily: 'Nunito',
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDeep,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: const DividerThemeData(space: 0, thickness: 1, color: Color(0xFFF1F0FF)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryIndigo,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryDeep,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDeep,
        brightness: Brightness.dark,
        primary: const Color(0xFF818CF8),
        secondary: accentAmber,
        surface: const Color(0xFF0F0E1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0E1A),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFF0F0E1A),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          fontFamily: 'Nunito',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1A1830),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2D2B4E), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1830),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2D2B4E), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2D2B4E), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
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

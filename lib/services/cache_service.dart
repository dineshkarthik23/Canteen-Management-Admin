import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _appStateKey = 'canteen_app_state_v1';
  static const _themeModeKey = 'canteen_theme_mode_v1';
  static const _isLoggedInKey = 'canteen_is_logged_in_v1';

  Future<void> saveAppState(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appStateKey, jsonEncode(state));
    } catch (_) {
      // Ignore cache write errors in demo mode.
    }
  }

  Future<Map<String, dynamic>?> loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_appStateKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (_) {
      // Ignore cache write errors in demo mode.
    }
  }

  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_themeModeKey);
      return switch (raw) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.light,
      };
    } catch (_) {
      return ThemeMode.light;
    }
  }

  Future<void> setLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, value);
    } catch (_) {
      // Ignore cache write errors in demo mode.
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (_) {
      return false;
    }
  }
}

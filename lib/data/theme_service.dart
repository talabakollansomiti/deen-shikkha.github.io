import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ডার্ক মোড ম্যানেজমেন্ট
class ThemeService {
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier(ThemeMode.light);

  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final dark = p.getBool('dark_mode') ?? false;
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggle() async {
    final p = await SharedPreferences.getInstance();
    final dark = mode.value != ThemeMode.dark;
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
    await p.setBool('dark_mode', dark);
  }
}

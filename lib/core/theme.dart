import 'package:flutter/material.dart';

/// Step5.5 UI/UXクオリティ設計：ダークモード必須／カード角丸+影／
/// タップ領域44pt以上を前提にしたテーマ定義。
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFFFF6A00); // 二輪エンジン×排気を想起する朱橙
  static const Color secondary = Color(0xFF1B2A4A);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF0E1220) : const Color(0xFFF7F7FA),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // 44pt+ 確保
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

// lib/src/config/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppTheme {
  // ライトテーマ
  static ThemeData light() {
    return ThemeData(
      colorScheme: lightColorScheme,
      useMaterial3: true,
      // その他のテーマ設定を追加可能
    );
  }
}
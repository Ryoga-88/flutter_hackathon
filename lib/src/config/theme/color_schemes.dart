// lib/src/config/theme/color_schemes.dart
import 'package:flutter/material.dart';

// ライトモード用のカラースキーマ定義
const lightColorScheme = ColorScheme(
  // 明るさ設定
  brightness: Brightness.light,
  
  // メインカラー
  primary: Color(0xFF6200EE),      // 濃い紫
  onPrimary: Colors.white,         // 白（primaryの上のテキスト）
  primaryContainer: Color(0xFFEADDFF), // 薄い紫
  onPrimaryContainer: Color(0xFF21005E), // 濃い紫（ほぼ黒）
  
  // セカンダリカラー
  secondary: Color(0xFF03DAC6),    // ティール
  onSecondary: Colors.black,       // 黒（secondaryの上のテキスト）
  secondaryContainer: Color(0xFFCEF6F0), // 薄いティール
  onSecondaryContainer: Color(0xFF003731), // 濃いティール（ほぼ黒）
  
  // 第三のカラー
  tertiary: Color(0xFFFF8A65),     // オレンジ
  onTertiary: Colors.black,        // 黒（tertiaryの上のテキスト）
  tertiaryContainer: Color(0xFFFFDBCF), // 薄いオレンジ
  onTertiaryContainer: Color(0xFF932100), // 濃いオレンジ（ほぼ黒）
  
  // エラーカラー
  error: Color(0xFFB00020),        // 赤
  onError: Colors.white,           // 白（errorの上のテキスト）
  errorContainer: Color(0xFFFFDAD6), // 薄い赤
  onErrorContainer: Color(0xFF410002), // 濃い赤（ほぼ黒）
  
  // 背景色
  background: Colors.white,        // 白
  onBackground: Colors.black,      // 黒（backgroundの上のテキスト）
  
  // 表面色
  surface: Colors.white,           // 白
  onSurface: Colors.black,         // 黒（surfaceの上のテキスト）
  
  // その他のバリエーション
  surfaceVariant: Color(0xFFE7E0EC), // 薄い灰色
  onSurfaceVariant: Color(0xFF49454F), // 濃い灰色
  outline: Color(0xFF79747E),      // 中間の灰色（アウトライン用）
  outlineVariant: Color(0xFFC4C7C5), // 薄い灰色（無効状態のアウトライン）
  
  // シャドウとスクリム
  shadow: Colors.black,            // 影の色
  scrim: Color(0x99000000),        // 半透明の黒（0.6透明度）
  
  // 反転色（ダークテーマ中の明るい表面など）
  inverseSurface: Color(0xFF313033), // 暗い灰色
  onInverseSurface: Color(0xFFF4EFF4), // 明るい灰色
  inversePrimary: Color(0xFFD0BCFF), // 明るい紫
  
  // Material 3 の色合い
  surfaceTint: Color(0xFF6200EE),  // 表面に色合いを加える色
);
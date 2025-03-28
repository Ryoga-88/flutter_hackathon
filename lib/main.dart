import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_hackathon/initialize_notification.dart';
import 'firebase_options.dart';
import 'src/app.dart'; // プロジェクトのルートからのインポート
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initNotifications();
  // **アプリ起動時にタイムゾーンを初期化**
  tzData.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo')); // 必要に応じて適切なタイムゾーンを設定
  runApp(const MyApp());
}

import 'package:flutter/material.dart';
import 'package:flutter_hackathon/src/app.dart';
import 'package:flutter_hackathon/src/screens/battle.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: handleNotificationResponse,
  );
  // Request permissions for iOS
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

// 通知をタップした時の処理
void handleNotificationResponse(NotificationResponse response) {
  MyApp.navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (context) => BattleScreen()),
  );
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/preferences_helper.dart';
import 'domain/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SharedPreferences
  await PreferencesHelper.instance.init();

  // Initialize SQLite database
  await DatabaseHelper.instance.initDatabase();

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Request permissions
  await _requestPermissions();

  runApp(
    const ProviderScope(
      child: MuazzinApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  // Location permission
  final locationStatus = await Permission.locationWhenInUse.status;
  if (locationStatus.isDenied) {
    await Permission.locationWhenInUse.request();
  }

  // Notification permission (Android 13+)
  final notificationStatus = await Permission.notification.status;
  if (notificationStatus.isDenied) {
    await Permission.notification.request();
  }

  // Exact alarms (Android 12+)
  final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
  if (exactAlarmStatus.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotif() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_notification');

    DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onSelectNotification,
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _notifications
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedFlutterDefault =
          await androidImplementation?.requestPermission();
      if (grantedFlutterDefault == null || grantedFlutterDefault == false) {
        AppSettings.openAppSettings();
      }
    }
  }

  static NotificationDetails _notificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    return NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<dynamic> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    print('id: $id');
  }

  static Future<void> showNotification({
    required int id,
    required String? title,
    required String? body,
  }) async {
    // Show notification
    return await _notifications.show(
      id,
      title,
      body,
      await _notificationDetails(),
    );
  }

  static void onSelectNotification(NotificationResponse details) {
    print(details);
  }
}

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_interval/flutter_date_interval.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:toucan/models/goalModel.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  List<DateTime> _notifDates = [];

  Future<void> initializeNotif() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('mipmap/ic_notification');

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

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    // Cancel all pending notifications
    _notifications.cancelAll();

    // Show notification
    return await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      await _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static void onSelectNotification(NotificationResponse details) {
    print(details);
  }

  void scheduleNotificationsFromGoal(
      {required List<GoalModel> goals,
      required TimeOfDay notificationTime,
      required String username}) {
    Set<DateTime> notifDatesSet = {};

    goals.forEach((goal) {
      // Merge all notif dates to a set (remove duplicates)
      notifDatesSet.addAll(_getNotifDates(goal));
    });

    List<DateTime> sortedNotifDates = notifDatesSet.toList();
    sortedNotifDates.sort();
    _notifDates = sortedNotifDates.take(7).toList();

    // Get the 7 soonest notif dates as a list
    print("==== SET OF DATES ====");
    int notificationId = 0;
    _notifDates.forEach((date) {
      DateTime dateTime = DateTime(date.year, date.month, date.day,
          notificationTime.hour, notificationTime.minute);

      // Check if user changed reminder time to earlier time than now
      // If user did, then don't schedule notification for today
      // Otherwise, tz will throw an error
      if (dateTime.isBefore(DateTime.now())) {
        return;
      }

      // Schedule notifications based on user's preferred
      // notification time
      showScheduledNotification(
        id: notificationId,
        title: "Goal Reminder",
        body:
            "Hey $username, let's keep on track.\nYou have goals to update today!",
        dateTime: dateTime,
      );
      print(
          "Dates: ${DateTime(date.year, date.month, date.day, notificationTime.hour, notificationTime.minute)}");
      notificationId++;
    });
  }

  // Get first seven dates on when to notify user
  Iterable<DateTime> _getNotifDates(GoalModel goal) {
    // check start date
    // if in progress, start is today
    DateTime start = goal.startDate;
    if (goal.status == "in-progress") start = DateTime.now();

    Intervals interval = _getIntervalFromFrequency(goal.frequency);
    DateInterval dateInterval =
        DateInterval(startDate: start, interval: interval, period: goal.period);

    // check end date to limit size of dateInterval iterable
    // if end date is 6 months or more from now,
    // set end date to 6 months from today
    DateTime sixMonthsFromToday = DateTime.now().add(Duration(days: 30 * 6));
    DateTime end = goal.endDate;
    if (goal.endDate.isAfter(sixMonthsFromToday)) end = sixMonthsFromToday;
    return dateInterval.getDatesThrough(end).take(7);
  }

  // Get interval from frequency of Goal
  Intervals _getIntervalFromFrequency(String frequency) {
    if (frequency == "day/s") return Intervals.daily;
    if (frequency == "week/s") return Intervals.weekly;
    if (frequency == "month/s") return Intervals.monthly;
    return Intervals.yearly;
  }
}

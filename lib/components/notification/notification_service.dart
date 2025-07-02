import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    await requestPermissions();
  }

  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Check current notification permission status
      PermissionStatus notificationStatus = await Permission.notification.status;

      if (notificationStatus.isDenied) {
        // First time asking or user hasn't permanently denied
        notificationStatus = await Permission.notification.request();
      }

      if (notificationStatus.isPermanentlyDenied || notificationStatus.isDenied) {
        print("Notification permission denied");
        return false;
      }

      // Check exact alarm permission
      final bool? exactAlarmsAllowed = await androidImplementation.canScheduleExactNotifications();
      print(exactAlarmsAllowed);

      if (exactAlarmsAllowed != true) {

        // Check again after request
        final bool? exactAlarmsStillAllowed = await androidImplementation.canScheduleExactNotifications();

        if (exactAlarmsStillAllowed != true) {
          print("Exact alarm permission denied");
          return false;
        }
      }

      // PermissionStatus batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      // if (batteryStatus.isDenied) {
      //   batteryStatus = await Permission.ignoreBatteryOptimizations.request();
      //   if (batteryStatus.isDenied) {
      //     print("Battery optimization exemption denied - notifications may be unreliable");
      //   }
      // }

      print('All permissions granted');
      return true;
    }
    return false;
  }

  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permissions Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app needs notification permissions to send you daily reminders.'),
                SizedBox(height: 10),
                Text('Please enable:'),
                Text('• Notifications')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // This opens the app settings
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> scheduleDailyNotification(TimeOfDay time) async {

    await _notificationsPlugin.zonedSchedule(
      0, // notification id
      'Daily Reminder', // title
      'Don\'t forget to check your app!', // body
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          channelDescription: 'Daily notification at 7 PM',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If it's already past 7 PM today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Check if notifications are scheduled
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
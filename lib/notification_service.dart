import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';


class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');  // Changed from 'app_icon'


    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        macOS: null);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotification(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
          // Handle notification action
            break;
        }
      },
    );

    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));

    // Create the notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permissions
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted.');
    } else if (status.isDenied) {
      print('Notification permission denied.');
    } else if (status.isPermanentlyDenied) {
      print('Notification permission permanently denied. Please enable it in app settings.');
      // Optionally, you can open the app settings:
      // await openAppSettings();
    }

    status = await Permission.scheduleExactAlarm.request();
    if (status.isGranted) {
      print('Exact alarm permission granted.');
    } else if (status.isDenied) {
      print('Exact alarm permission denied. Falling back to inexact alarms.');
    } else if (status.isPermanentlyDenied) {
      print('Exact alarm permission permanently denied. Please enable it in app settings.');
      // Optionally, you can open the app settings:
      // await openAppSettings();
    }
  }

  Future selectNotification(String? payload) async {
    // Handle notification tapped logic here
  }

  Future<void> showNotification(int id, String title, String body, DateTime eventDate) async {
    if (await Permission.notification.isGranted) {
      tz.TZDateTime scheduledDate = tz.TZDateTime.from(
          eventDate.subtract(Duration(minutes: 1)), tz.local);

      // Ensure the scheduled time is in the future
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Scheduled time is in the past.');
        return;
        // scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(minutes: 2));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.max,
            ticker: 'ticker',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
      );
      print('Notification scheduled for: ${scheduledDate.toString()}');
    } else {
      print(
          'Notification permission not granted. Unable to show notification.');
    }
  }

  Future<void> showImmediateNotification(int id, String title, String body) async {
    if (await Permission.notification.isGranted) {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
      );
    } else {
      print('Notification permission not granted. Unable to show notification.');
    }
  }


  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
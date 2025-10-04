import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  final String title;
  final String message;
  final String time;

  NotificationModel({required this.title, required this.message, required this.time});
}

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  void _initNotifications() async {
    // Local notifications setup
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );

        notifications.insert(
          0,
          NotificationModel(
            title: notification.title ?? 'No Title',
            message: notification.body ?? 'No Message',
            time: DateTime.now().toString(),
          ),
        );
      }
    });

    // When app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 Notification Clicked: ${message.notification?.title}");
    });
  }
}

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'navigation_service.dart';

class NotificationService {
  static Future initialize(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    var androidInitialize =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iOSInitialize =
        const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null &&
            notificationResponse.payload!.isNotEmpty) {
          var payload = jsonDecode(notificationResponse.payload!);
          if (payload['navigate_to'] != null &&
              payload['navigate_to'].isNotEmpty) {
            NavigationService.instance
                .navigateTo(payload['navigate_to'], arguments: payload['data']);
          }
        }
      },
    );
  }

  static Future showBigTextNotification({
    required String title,
    required String body,
    required FlutterLocalNotificationsPlugin fln,
    int id = 0,
    String? payload,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'default_.notification_channel_id',
      'channel_name',
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    var not = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );
    await fln.show(
      id,
      title,
      body,
      not,
      payload: payload,
    );
  }
}

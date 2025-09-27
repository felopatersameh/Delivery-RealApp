import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../Local/local_storage.dart';
import '../Local/local_storage_keys.dart';

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio _dio = Dio();

  initFCM() async {
    await _firebaseMessaging.requestPermission();
    final tokenFCM = await _firebaseMessaging.getToken();
    LocalStorageService.setValue(LocalStorageKeys.tokenFCM, tokenFCM);
    debugPrint("tokenFCM:: $tokenFCM");

    FirebaseMessaging.onMessageOpenedApp.listen((onData) async {
      debugPrint("onMessageOpenedAppData:: ${onData.notification?.toMap()}");
    });
    FirebaseMessaging.onMessage.listen((onData) async {
      debugPrint("onMessage:: ${onData.notification?.toMap()}");
    });
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required List<String> tokens,
  }) async {
    try {
      const String serverKey = 'YOUR_SERVER_KEY_HERE'; // ضع المفتاح هنا

      for (final token in tokens) {
        final payload = {
          "to": token,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
          }
        };

        await _dio.post(
          'https://fcm.googleapis.com/fcm/send',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'key=$serverKey',
            },
          ),
          data: jsonEncode(payload),
        );
      }

      debugPrint('🔔 Notifications sent to ${tokens.length} users.');
    } catch (e) {
      debugPrint('❌ Error sending notifications: $e');
    }
  }
}

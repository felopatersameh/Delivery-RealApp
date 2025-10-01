import 'dart:convert';
import '../Local/local_storage.dart';
import '../Local/local_storage_keys.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

import 'flutter_local_notifications.dart';

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio _dio = Dio();

  Future<void> initFCM() async {
    await _firebaseMessaging.requestPermission();
    final tokenFCM = await _firebaseMessaging.getToken();
    // debugPrint("✅ tokenFCM:: $tokenFCM");
    final tokenIn = await LocalStorageService.getValue(
      LocalStorageKeys.tokenFCM,
      defaultValue: null,
    );
    if (tokenIn == null || tokenIn == '' && tokenFCM != tokenIn) {
      await LocalStorageService.setValue(LocalStorageKeys.tokenFCM, tokenFCM);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((message)async {
      // debugPrint(
      //   "📲 onMessageOpenedAppData:: ${message.notification?.toMap()}",
      // );
    });

    FirebaseMessaging.onMessage.listen((message)async {
      // debugPrint("📥 onMessage:: ${message.notification?.toMap()}");
      final notification = message.notification;

      if (notification != null) {
        final title = notification.title ?? 'No Title';
        final body = notification.body ?? 'No Body';

      await  LocalNotificationService.showNotification(title: title, body: body);
      }
    });
  }

  Future<ServiceAccountCredentials> _loadServiceAccount() async {
    final jsonStr = await rootBundle.loadString('Assets/service_account.json');
    return ServiceAccountCredentials.fromJson(jsonStr);
  }

  Future<String> _getAccessToken() async {
    final credentials = await _loadServiceAccount();
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient = await clientViaServiceAccount(credentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  Future<void> sendNotification({
    required List<String> tokens,
    required Map<String, dynamic> payloadData,
  }) async {
    final accessToken = await _getAccessToken();
    const projectId = 'areameasurement-21340';

    for (final token in tokens) {
      final payload = {
        "message": {
          "token": token,
          "notification": {
            "title": payloadData['title'],
            "body": payloadData['body'],
            if (payloadData['image'] != null) "image": payloadData['image'],
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
            ...payloadData['data'] ?? {},
          },
        },
      };

      try {
        final response = await _dio.post(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
          data: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          // debugPrint('✅ Notification sent to $token');
        } else {
          // debugPrint(
          //   '❌ Error sending to $token: ${response.statusCode} - ${response.data}',
          // );
        }
      } catch (e) {
        // debugPrint('❌ Dio error: $e');
      }
    }
  }
}

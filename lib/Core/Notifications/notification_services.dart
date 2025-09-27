import 'package:delivery/Core/Local/local_storage.dart';
import 'package:delivery/Core/Local/local_storage_keys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

class NotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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

  Future<void> sendNotification() async {}
}

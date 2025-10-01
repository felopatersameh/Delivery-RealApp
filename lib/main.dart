import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';

import 'Core/Local/local_storage.dart';
import 'Core/Notifications/flutter_local_notifications.dart';
import 'Features/Orders/Cubit/order_cubit.dart';
import 'Features/Profile/cubit/profile_cubit.dart';
import 'Features/Splash/splash_screen.dart';

import 'Core/Database/real_time_firbase.dart';
import 'Core/Notifications/notification_services.dart';
import 'Features/Products/cubit/products_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LocalStorageService.init(boxName: "delivery_storge");
  //*Init Firbase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //* Notifications
  await LocalNotificationService.initialize();
  final NotificationServices notificationServices = NotificationServices();
  await notificationServices.initFCM();
  FirebaseMessaging.onBackgroundMessage(handlerOnBackgroundMessage);
  //*Real Time
  await RealtimeFirebase.initialize();

  //* run App
  runApp(const App());
}

@pragma('vm:entry-point')
Future<void> handlerOnBackgroundMessage(RemoteMessage onData) async {
  // debugPrint("onMessage:: ${onData.notification?.toMap()}");
 final notification = onData.notification;

  if (notification != null) {
    final title = notification.title ?? 'No Title';
    final body = notification.body ?? 'No Body';

   await LocalNotificationService.showNotification(
      title: title,
      body: body,
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => ProductsCubit()),
        BlocProvider(create: (context) => OrdersCubit()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        enableScaleWH: () => false,
        enableScaleText: () => true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Delivery app',
          home: SplashApp(),
        ),
      ),
    );
  }
}

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Enum/message_type.dart';
import 'package:flutter/material.dart';

Future<void> showMessageSnackBar(
  BuildContext context, {
  required String title,
  required MessageType type,
  Future<void> Function()? onLoading,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  if (type == MessageType.loading && onLoading != null) {
    // إظهار SnackBar مؤقتة أثناء التنفيذ
    final snackBar = SnackBar(
      content: Row(
        children: [
           SizedBox(
            height: 20.h,
            width: 20.w,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
           SizedBox(width: 12.w),
          Expanded(child: Text(title)),
        ],
      ),
      backgroundColor: type.backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(10).r,
      duration: const Duration(hours: 1), // مؤقت طويل (هيتم إغلاقه يدويًا)
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

    try {
      await onLoading(); // تنفيذ العملية
    } finally {
      messenger.hideCurrentSnackBar(); // إغلاق الإشعار بعد التنفيذ
    }

    return;
  }

  // حالات غير loading
  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(type.icon, color: Colors.white),
         SizedBox(width: 12.w),
        Expanded(child: Text(title)),
      ],
    ),
    backgroundColor: type.backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(10).r,
    duration: const Duration(seconds: 3),
  );

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

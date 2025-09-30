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
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      backgroundColor: type.backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
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
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
      ],
    ),
    backgroundColor: type.backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  );

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

import 'package:flutter/material.dart';

enum MessageType {
  success(backgroundColor: Colors.green, icon: Icons.check_circle),
  error(backgroundColor: Colors.red, icon: Icons.error),
  pending(backgroundColor: Colors.blueGrey, icon: Icons.hourglass_bottom),
  rejected(backgroundColor: Colors.deepOrange, icon: Icons.cancel),
  warning(backgroundColor: Colors.amber, icon: Icons.warning),
  info(backgroundColor: Colors.blue, icon: Icons.info),
  loading(backgroundColor: Colors.black87, icon: Icons.hourglass_top);

  final Color backgroundColor;
  final IconData icon;

  const MessageType({required this.backgroundColor, required this.icon});
}

import 'package:flutter/material.dart';

enum UserType {
  client('Client', Colors.blue, Icons.person),
  admin('Admin', Colors.red, Icons.admin_panel_settings),
  vendor('Vendor', Colors.green, Icons.store),
  moderator('Moderator', Colors.orange, Icons.supervised_user_circle);

  const UserType(this.displayName, this.color, this.icon);

  final String displayName;
  final Color color;
  final IconData icon;
  static UserType? fromName(String name) {
    return UserType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => UserType.client,
    );
  }
}

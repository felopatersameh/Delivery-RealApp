import 'package:flutter/material.dart';

enum UserType {
  client('Client', Colors.blue, Icons.person),
  vendor('vendor', Colors.red, Icons.store),
  // vendor('Vendor', Colors.green, Icons.store),
  delivery('delivery', Colors.orange, Icons.delivery_dining_sharp),
  non('None', Colors.grey, Icons.block);

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

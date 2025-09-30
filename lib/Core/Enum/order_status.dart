import 'package:flutter/material.dart';

enum OrderStatus {
  pending('pending', 'Pending', Colors.orange, Icons.hourglass_empty),
  removed('removed', 'Cancelled by Client', Colors.grey, Icons.cancel),
  rejected('rejected', 'Rejected by Vendor', Colors.red, Icons.close),
  searching('searching', 'Searching for Delivery', Colors.blue, Icons.search),
  running('running', 'Out for Delivery', Colors.purple, Icons.local_shipping),
  finished('finished', 'Delivered', Colors.green, Icons.check_circle);

  const OrderStatus(this.value, this.displayName, this.color, this.icon);
  final String value;
  final String displayName;
  final Color color;
  final IconData icon;

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  // Status transition validation
  bool canTransitionTo(OrderStatus newStatus) {
    switch (this) {
      case OrderStatus.pending:
        return [
          OrderStatus.removed,
          OrderStatus.rejected,
          OrderStatus.searching,
        ].contains(newStatus);
      case OrderStatus.searching:
        return [OrderStatus.running, OrderStatus.rejected].contains(newStatus);
      case OrderStatus.running:
        return [OrderStatus.finished].contains(newStatus);
      case OrderStatus.removed:
      case OrderStatus.rejected:
      case OrderStatus.finished:
        return false; // Final states cannot transition
    }
  }

  // Get allowed next statuses
  List<OrderStatus> getAllowedTransitions() {
    switch (this) {
      case OrderStatus.pending:
        return [
          OrderStatus.removed,
          OrderStatus.rejected,
          OrderStatus.searching,
        ];
      case OrderStatus.searching:
        return [OrderStatus.running, OrderStatus.rejected];
      case OrderStatus.running:
        return [OrderStatus.finished];
      default:
        return [];
    }
  }

  // Check if status is final (cannot be changed)
  bool get isFinal => [
    OrderStatus.removed,
    OrderStatus.rejected,
    OrderStatus.finished,
  ].contains(this);

  // Check if order is active
  bool get isActive =>
      [OrderStatus.searching, OrderStatus.running].contains(this);

  // Check if order is completed
  bool get isCompleted => this == OrderStatus.finished;

  // Check if order is cancelled
  bool get isCancelled =>
      [OrderStatus.removed, OrderStatus.rejected].contains(this);
}

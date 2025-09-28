import 'package:meta/meta.dart';

import '../Models/order_model.dart';

@immutable
class OrdersState {
  final List<OrderModel>? orders;
  final bool isLoading;
  final String? errorMessage;
  final int badge;
  final List<String> newOrderIds;

  const OrdersState({
    this.orders,
    this.isLoading = false,
    this.errorMessage,
    this.badge = 0,
    this.newOrderIds = const [],
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? errorMessage,
    int? badge,
    List<String>? newOrderIds,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      badge: badge ?? this.badge,
      newOrderIds: newOrderIds ?? this.newOrderIds,
    );
  }
}

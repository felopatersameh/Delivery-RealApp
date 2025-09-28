import 'package:delivery/Core/Enum/order_status.dart';
import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Features/Orders/Models/order_model.dart';
import 'package:delivery/Features/Orders/Models/order_product.dart';
import 'package:delivery/Features/Profile/Model/user_modell.dart';

class OrderManager {
  /// Create a new order
  static OrderModel createOrder({
    required List<OrderProduct> products,
    required UserModell client,
    String? vendorId,
    String? notes,
  }) {
    final totalPrice = products.fold(
      0.0,
      (sum, product) => sum + product.product.price,
    );
    final now = DateTime.now();

    return OrderModel(
      orderID: '${now.millisecondsSinceEpoch}',
      totalPrice: totalPrice,
      products: products,
      client: client,
      vendorId: vendorId,
      delivery: UserModell.empty(),
      status: OrderStatus.pending,
      createdAt: now,
      updatedAt: now,
      notes: notes,
    );
  }

  /// Get orders by status
  static List<OrderModel> filterOrdersByStatus(
    List<OrderModel> orders,
    OrderStatus status,
  ) {
    return orders.where((order) => order.status == status).toList();
  }

  /// Get orders for specific user
  static List<OrderModel> getOrdersForUser(
    List<OrderModel> orders,
    String userId,
    UserType userType,
  ) {
    switch (userType) {
      case UserType.client:
        return orders.where((order) => order.belongsToClient(userId)).toList();
      case UserType.vendor:
        return orders.where((order) => order.belongsToVendor(userId)).toList();
      case UserType.delivery:
        return orders
            .where(
              (order) =>
                  order.status == OrderStatus.searching ||
                  order.belongsToDelivery(userId),
            )
            .toList();

      case UserType.non:
        return [] ;
    }
  }

  /// Calculate total revenue for vendor
  static double calculateVendorRevenue(
    List<OrderModel> orders,
    String vendorId,
  ) {
    return orders
        .where(
          (order) =>
              order.belongsToVendor(vendorId) && order.status.isCompleted,
        )
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  /// Get active orders count
  static int getActiveOrdersCount(List<OrderModel> orders) {
    return orders.where((order) => order.status.isActive).length;
  }

  /// Sort orders by creation date
  static List<OrderModel> sortOrdersByDate(
    List<OrderModel> orders, {
    bool ascending = false,
  }) {
    final sorted = List<OrderModel>.from(orders);
    sorted.sort(
      (a, b) => ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt),
    );
    return sorted;
  }
}

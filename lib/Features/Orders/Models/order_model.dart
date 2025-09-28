import 'package:delivery/Core/Enum/order_status.dart';
import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Features/Orders/Models/order_product.dart';
import 'package:delivery/Features/Profile/Model/user_modell.dart';

class OrderModel {
  final String orderID;
  final double totalPrice;
  final List<OrderProduct> products;
  final UserModell client;
  final String? vendorId;
  final UserModell delivery;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final String? rejectionReason;

  OrderModel({
    required this.orderID,
    required this.totalPrice,
    required this.products,
    required this.client,
     this.vendorId,
    required this.delivery,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.rejectionReason,
  });

factory OrderModel.fromJson(String? orderId, Map<String, dynamic> json) {
  return OrderModel(
    orderID: json['orderID'] ?? orderId ?? '',
    totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    products: (json['products'] as List<dynamic>?)
            ?.map((p) => OrderProduct.fromJson(p))
            .toList() ??
        [],
    client: UserModell.fromJson(json['client']),
    vendorId: json['vendorId'] ?? '',
    delivery: UserModell.fromJson(json['delivery']),
    status: OrderStatus.fromValue(json['status'] ?? 'pending'),
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] ?? 0),
    notes: json['notes'] ?? "_",
    rejectionReason: json['rejectionReason'] ?? "_",
  );
}


  Map<String, dynamic> toJson() {
    return {
      'totalPrice': totalPrice,
      'products': products.map((p) => p.toJson()).toList(),
      'client': client.toJson(),
      'vendorId': vendorId,
      'delivery': delivery.isEmpty ? null : delivery.toJson(),
      'status': status.value,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'notes': notes?? "",
      'rejectionReason': rejectionReason ??"",
    };
  }

  OrderModel copyWith({
    String? orderID,
    double? totalPrice,
    List<OrderProduct>? products,
    UserModell? client,
    String? vendorId,
    UserModell? delivery,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? rejectionReason,
  }) {
    return OrderModel(
      orderID: orderID ?? this.orderID,
      totalPrice: totalPrice ?? this.totalPrice,
      products: products ?? this.products,
      client: client ?? this.client,
      vendorId: vendorId ?? this.vendorId,
      delivery: delivery ?? this.delivery,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Status Management Methods
  
  /// Change order status with validation
  OrderModel changeStatus(OrderStatus newStatus, {String? reason}) {
    if (!status.canTransitionTo(newStatus)) {
      throw Exception('Cannot change status from ${status.displayName} to ${newStatus.displayName}');
    }
    
    return copyWith(
      status: newStatus,
      rejectionReason: newStatus == OrderStatus.rejected ? reason : rejectionReason,
      updatedAt: DateTime.now(),
    );
  }

  /// Client cancels the order (only from pending)
  OrderModel cancelByClient() {
    if (status != OrderStatus.pending) {
      throw Exception('Order can only be cancelled when pending');
    }
    return changeStatus(OrderStatus.removed);
  }

  /// Vendor rejects the order
  OrderModel rejectByVendor({required String reason}) {
    if (![OrderStatus.pending, OrderStatus.searching].contains(status)) {
      throw Exception('Order can only be rejected from pending or searching status');
    }
    return changeStatus(OrderStatus.rejected, reason: reason);
  }

  /// Vendor approves order and starts searching for delivery
  OrderModel approveAndSearchDelivery() {
    if (status != OrderStatus.pending) {
      throw Exception('Order must be pending to start delivery search');
    }
    return changeStatus(OrderStatus.searching);
  }

  /// Assign delivery person and start running
  OrderModel assignDeliveryAndStart(UserModell deliveryPerson) {
    if (status != OrderStatus.searching) {
      throw Exception('Order must be in searching status to assign delivery');
    }
    return copyWith(
      delivery: deliveryPerson,
      status: OrderStatus.running,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark order as finished (delivered)
  OrderModel markAsFinished({String? deliveryNotes}) {
    if (status != OrderStatus.running) {
      throw Exception('Order must be running to mark as finished');
    }
    return copyWith(
      status: OrderStatus.finished,
      notes: deliveryNotes ?? notes,
      updatedAt: DateTime.now(),
    );
  }

  // Utility Methods

  /// Get order short ID (first 8 characters)
  String get shortId => 'ORD_${orderID.length > 8 ? orderID.substring(0, 8) : orderID}';

  /// Get total items count
  int get totalItems => products.fold(0, (sum, product) => sum + product.quantity);

  /// Check if order belongs to user
  bool belongsToClient(String clientId) => client.id == clientId;
  bool belongsToVendor(String vendorId) => products.first.product.vendorId == vendorId;
  bool belongsToDelivery(String deliveryId) => delivery.id == deliveryId;

  /// Get allowed actions for user type
  List<String> getAllowedActionsForUser(UserType userType, String userId) {
    List<String> actions = [];

    switch (userType) {
      case UserType.client:
        if (belongsToClient(userId)) {
          if (status == OrderStatus.pending) {
            actions.add('Cancel Order');
          }
          if (status == OrderStatus.running) {
            actions.add('Mark as Received');
          }
        }
        break;

      case UserType.vendor:
        if (belongsToVendor(userId)) {
          if (status == OrderStatus.pending) {
            actions.addAll(['Accept Order', 'Reject Order']);
          }
          if (status == OrderStatus.searching) {
            actions.add('Reject Order');
          }
        }
        break;

        case UserType.non :
        break;

      case UserType.delivery:
        if (status == OrderStatus.searching) {
          actions.add('Accept Delivery');
        }
        if (belongsToDelivery(userId) && status == OrderStatus.running) {
          actions.add('Mark as Delivered');
        }
        break;
    }

    return actions;
  }

  /// Format order creation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get status progress (0.0 to 1.0)
  double get statusProgress {
    switch (status) {
      case OrderStatus.pending:
        return 0.2;
      case OrderStatus.searching:
        return 0.4;
      case OrderStatus.running:
        return 0.8;
      case OrderStatus.finished:
        return 1.0;
      case OrderStatus.removed:
      case OrderStatus.rejected:
        return 0.0;
    }
  }

  /// Check if order can be modified
  bool get canBeModified => status == OrderStatus.pending;

  /// Check if delivery tracking is available
  bool get hasDeliveryTracking => status.isActive && delivery.isNotEmpty;

  @override
  String toString() {
    return 'Order(${shortId}, ${status.displayName}, \$${totalPrice.toStringAsFixed(2)})';
  }
}

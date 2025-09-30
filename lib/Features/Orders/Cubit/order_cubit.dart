// orders_cubit.dart
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../Core/Database/real_time_firbase.dart';
import '../../../Core/Enum/order_status.dart';
import '../../../Core/Enum/user_type.dart';
import '../../../Core/Local/local_storage.dart';
import '../../../Core/Local/local_storage_keys.dart';
import '../../../Features/Profile/Model/user_modell.dart';
import '../../Products/Model/product_model.dart';
import '../Models/order_manager.dart';
import '../Models/order_model.dart';
import '../Models/order_product.dart';
import 'order_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersState());

  String? _listenerId;
  UserType? currentUserType;
  String? currentUserId;

  Future<void> init() async {
    try {
      emit(state.copyWith(isLoading: true));

      currentUserId = await LocalStorageService.getValue(
        LocalStorageKeys.idUser,
      );
      final userTypeString = await LocalStorageService.getValue(
        LocalStorageKeys.statusUser,
      );
      currentUserType = UserType.fromName(userTypeString);

      await _loadInitialOrders();
      _listenToOrderChanges();

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error loading orders: $e',
        ),
      );
      debugPrint('Error loading orders: $e');
    }
  }

  Future<void> _loadInitialOrders() async {
    final List<String> oldIds = List<String>.from(
      await LocalStorageService.getValue(
        LocalStorageKeys.idOrders,
        defaultValue: [],
      ),
    );

    final data = await RealtimeFirebase.getData('orders');
    final raw = Map<String, dynamic>.from(data ?? {});
    final allOrders = raw.entries.map((entry) {
      final key = entry.key;
      final map = (entry.value is Map)
          ? (entry.value as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      return OrderModel.fromJson(key, map);
    }).toList();
    // Filter orders based on user type
    final filteredOrders = OrderManager.getOrdersForUser(
      allOrders,
      currentUserId,
      currentUserType,
    );
    final allIds = filteredOrders.map((e) => e.orderID).toList();
    await LocalStorageService.setValue(LocalStorageKeys.idOrders, allIds);

    final addedIds = filteredOrders
        .where((order) => !oldIds.contains(order.orderID))
        .map((e) => e.orderID)
        .toList();

      filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(
      state.copyWith(
        orders: filteredOrders,
        badge: addedIds.length,
        newOrderIds: addedIds,
      ),
    );
  }

  void _listenToOrderChanges() async {
    _listenerId = RealtimeFirebase.listen('orders', (data, _) async {
      final oldOrders = state.orders ?? [];
      final oldIds = oldOrders.map((e) => e.orderID).toSet();

      final raw = Map<String, dynamic>.from(data ?? {});
      final updatedIds = raw.keys.toSet();
      final removedIds = oldIds.difference(updatedIds).toList();

      final allUpdatedOrders = raw.entries.map((entry) {
        final key = entry.key;
        final map = Map<String, dynamic>.from(entry.value);
        return OrderModel.fromJson(key, map);
      }).toList();

      // Filter orders based on user type
      final updatedOrders = OrderManager.getOrdersForUser(
        allUpdatedOrders,
        currentUserId,
        currentUserType,
      );

      final newIds = updatedOrders
          .where((order) => !oldIds.contains(order.orderID))
          .map((e) => e.orderID)
          .toList();

      final bool hasAddition = newIds.isNotEmpty;
      final bool hasDeletion = removedIds.isNotEmpty;
      final bool hasModification = updatedOrders.any((newOrder) {
        final oldOrder = oldOrders.firstWhere(
          (e) => e.orderID == newOrder.orderID,
          orElse: () => newOrder,
        );
        return oldOrder.toJson().toString() != newOrder.toJson().toString();
      });

      if (!(hasAddition || hasDeletion || hasModification)) {
        return;
      }

      await LocalStorageService.setValue(
        LocalStorageKeys.idOrders,
        updatedOrders.map((e) => e.orderID).toList(),
      );
        updatedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(
        state.copyWith(
          orders: updatedOrders,
          badge: newIds.length,
          newOrderIds: newIds,
        ),
      );
    }, onError: (error) => log('Order listen error: $error'));
  }

  // Order management methods
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? reason,
    UserModell? deliveryPerson,
  }) async {
    try {
      final orderIndex = state.orders?.indexWhere((o) => o.orderID == orderId);
      if (orderIndex == null || orderIndex == -1) return;

      final order = state.orders![orderIndex];
      OrderModel updatedOrder;

      switch (newStatus) {
        case OrderStatus.removed:
          updatedOrder = order.cancelByClient();
          state.orders?.removeWhere(
            (order) => order.orderID == updatedOrder.orderID,
          );
          emit(state.copyWith(orders: state.orders));
          break;
        case OrderStatus.rejected:
          updatedOrder = order.rejectByVendor(
            reason: reason ?? 'No reason provided',
          );
          break;
        case OrderStatus.searching:
          updatedOrder = order.approveAndSearchDelivery();
          break;
        case OrderStatus.running:
          assignDeliveryAndStart(orderId, deliveryPerson!);
          return;
        case OrderStatus.finished:
          updatedOrder = order.markAsFinished();
          break;
        default:
          updatedOrder = order.changeStatus(newStatus, reason: reason);
      }
      await RealtimeFirebase.updateData(
        'orders/$orderId',
        updatedOrder.toJson(),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> assignDeliveryAndStart(
    String orderId,
    UserModell deliveryPerson,
  ) async {
    try {
      final orderIndex = state.orders?.indexWhere((o) => o.orderID == orderId);
      if (orderIndex == null || orderIndex == -1) return;

      final order = state.orders![orderIndex];
      final updatedOrder = order.assignDeliveryAndStart(deliveryPerson);

      await RealtimeFirebase.updateData(
        'orders/$orderId',
        updatedOrder.toJson(),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<bool> handleProductAdd(ProductModel product, int quantity) async {
    final orders = state.orders;
    final pendingOrders = orders
        ?.where((o) => o.status == OrderStatus.pending)
        .toList();

    if (pendingOrders?.isEmpty == true) {
      // No pending order → create new
      return false;
    }

    OrderModel? existing;

    for (var order in pendingOrders!) {
      if (order.vendorId == product.vendorId) {
        existing = order;
        break;
      }
    }

    if (existing != null) {
      bool found = false;

      for (var p in existing.products) {
        if (p.product.id == product.id) {
          p.quantity += quantity;
          found = true;
          break;
        }
      }

      if (!found) {
        existing.products.add(
          OrderProduct(product: product, quantity: quantity),
        );
      }

      // Update the order in Firebase
      await RealtimeFirebase.updateData(
        'orders/${existing.orderID}',
        existing.toJson(),
      );

      return true;
    }

    return false; // Vendor mismatch → create new
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      await RealtimeFirebase.create('orders', order.toJson());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void resetBadge() => emit(state.copyWith(badge: 0, newOrderIds: []));

  // Get user-specific allowed actions
  List<String> getAllowedActionsForOrder(OrderModel order) {
    if (currentUserType == null || currentUserId == null) return [];
    return order.getAllowedActionsForUser(currentUserType!, currentUserId!);
  }

  @override
  Future<void> close() {
    if (_listenerId != null) {
      RealtimeFirebase.unlisten(_listenerId!);
    }
    return super.close();
  }
}

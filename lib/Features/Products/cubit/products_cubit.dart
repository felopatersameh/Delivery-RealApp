import 'dart:developer';
import 'package:bloc/bloc.dart';
import '../../../Core/Notifications/get_tokens_f_c_m.dart';
import '../../Profile/Model/user_modell.dart';
import 'package:flutter/material.dart';
import '../../../Core/Database/real_time_firbase.dart';
import '../../../Core/Enum/user_type.dart';
import '../../../Core/Local/local_storage.dart';
import '../../../Core/Local/local_storage_keys.dart';
import '../../../Core/Notifications/notification_services.dart';
import '../../../Core/Notifications/notifications_model.dart';
import '../Model/product_model.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(const ProductsState());
  NotificationServices notificationServices = NotificationServices();

  String? _listenerId;
  UserType? currentUserType;

  Future<void> init() async {
    try {
      await _loadInitialProducts();
      _listenToProductChanges();
    } catch (e) {
      // debugPrint('Error loading products: $e');
    }
  }

  Future<void> _loadInitialProducts() async {
    final idUser = await LocalStorageService.getValue(LocalStorageKeys.idUser);
    final String typeUser = await LocalStorageService.getValue(
      LocalStorageKeys.statusUser,
    );
    currentUserType = UserType.fromName(typeUser);

    final List<String> oldIds = List<String>.from(
      await LocalStorageService.getValue(
        LocalStorageKeys.idProducts,
        defaultValue: [],
      ),
    );

    final data = await RealtimeFirebase.getData('products');
    final raw = Map<String, dynamic>.from(data ?? {});

    final allProducts = raw.entries.map((entry) {
      final key = entry.key;
      final map = Map<String, dynamic>.from(entry.value);
      return ProductModel.fromJson(key, map);
    }).toList();

    // فلترة المنتجات حسب نوع المستخدم
    List<ProductModel> filteredProducts = [];

    if (currentUserType == UserType.client) {
      filteredProducts = allProducts
          .where((p) => p.vendorId != idUser)
          .toList();
    } else if (currentUserType == UserType.vendor) {
      filteredProducts = allProducts
          .where((p) => p.vendorId == idUser)
          .toList();
    } else {
      // غير مسموح لأي نوع آخر
      filteredProducts = [];
    }

    final allIds = filteredProducts.map((e) => e.id).toList();
    final addedIds = filteredProducts
        .where((p) => !oldIds.contains(p.id))
        .map((e) => e.id)
        .toList();

    await LocalStorageService.setValue(LocalStorageKeys.idProducts, allIds);
    //  filteredProducts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    emit(
      state.copyWith(
        products: filteredProducts,
        badge: addedIds.length,
        newProducstIds: addedIds,
      ),
    );
  }

  void _listenToProductChanges() async {
    final idUser = await LocalStorageService.getValue(LocalStorageKeys.idUser);
    final String typeUser = await LocalStorageService.getValue(
      LocalStorageKeys.statusUser,
    );
    currentUserType = UserType.fromName(typeUser);

    _listenerId = RealtimeFirebase.listen('products', (data, _) async {
      final oldProducts = state.products ?? [];
      final oldIds = oldProducts.map((e) => e.id).toSet();

      final raw = Map<String, dynamic>.from(data ?? {});
      final allUpdated = raw.entries.map((entry) {
        final key = entry.key;
        final map = Map<String, dynamic>.from(entry.value);
        return ProductModel.fromJson(key, map);
      }).toList();

      // فلترة حسب نوع المستخدم
      List<ProductModel> updatedProducts = [];

      if (currentUserType == UserType.client) {
        updatedProducts = allUpdated
            .where((p) => p.vendorId != idUser)
            .toList();
      } else if (currentUserType == UserType.vendor) {
        updatedProducts = allUpdated
            .where((p) => p.vendorId == idUser)
            .toList();
      } else {
        updatedProducts = [];
      }

      final updatedIds = updatedProducts.map((e) => e.id).toSet();
      final removedIds = oldIds.difference(updatedIds).toList();

      final newIds = updatedProducts
          .where((p) => !oldIds.contains(p.id))
          .map((e) => e.id)
          .toList();

      final bool hasAddition = newIds.isNotEmpty;
      final bool hasDeletion = removedIds.isNotEmpty;
      final bool hasModification = updatedProducts.any((newProduct) {
        final oldProduct = oldProducts.firstWhere(
          (e) => e.id == newProduct.id,
          orElse: () => newProduct,
        );
        return oldProduct.toJson().toString() != newProduct.toJson().toString();
      });

      if (!(hasAddition || hasDeletion || hasModification)) {
        return;
      }

      await LocalStorageService.setValue(
        LocalStorageKeys.idProducts,
        updatedProducts.map((e) => e.id).toList(),
      );
      updatedProducts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(
        state.copyWith(
          products: updatedProducts,
          badge: newIds.length,
          newProducstIds: newIds,
        ),
      );
    }, onError: (error) => log('Product listen error: $error'));
  }

  Future<void> deleteProduct(String productId) async {
    await RealtimeFirebase.deleteData('products/$productId');
  }

  Future<void> addProduct(ProductModel product, UserModell user) async {
    await RealtimeFirebase.create('products', product.toJson());
    NotificationModel model = NotificationModel(
      title: "New Products",
      body: "${user.name} is Created ${product.name}",
    );
    final tokens = await GetTokensFCM.getTokensByUserType(
      UserType.client.displayName.toLowerCase(),
    );
    await notificationServices.sendNotification(
      payloadData: model.toPayload(),
      tokens: tokens,
    );
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    await RealtimeFirebase.updateData('products/$productId', updates);
  }

  void resetBadge() {
    emit(state.copyWith(badge: 0, newProducstIds: []));
  }

  @override
  Future<void> close() {
    if (_listenerId != null) {
      RealtimeFirebase.unlisten(_listenerId!);
    }
    return super.close();
  }
}

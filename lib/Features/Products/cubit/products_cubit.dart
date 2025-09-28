import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../Core/Database/real_time_firbase.dart';
import '../../../Core/Local/local_storage.dart';
import '../../../Core/Local/local_storage_keys.dart';
import '../Model/product_model.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(const ProductsState());

  String? _listenerId;

  Future<void> init() async {
    try {
      await _loadInitialProducts();
      _listenToProductChanges();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> _loadInitialProducts() async {
    final idUser = await LocalStorageService.getValue(LocalStorageKeys.idUser);
    final List<String> oldIds = List<String>.from(
      await LocalStorageService.getValue(
        LocalStorageKeys.idProducts,
        defaultValue: [],
      ),
    );

    final data = await RealtimeFirebase.getData('products');
    final raw = Map<String, dynamic>.from(data ?? {});

    final products = raw.entries.map((entry) {
      final key = entry.key;
      final map = Map<String, dynamic>.from(entry.value);
      return ProductModel.fromJson(key, map);
    }).toList();

    final allIds = products.map((e) => e.id).toList();
    await LocalStorageService.setValue(LocalStorageKeys.idProducts, allIds);

    final addedIds = products
        .where(
          (product) =>
              !oldIds.contains(product.id) && product.vendorId != idUser,
        )
        .map((e) => e.id)
        .toList();

    emit(
      state.copyWith(
        products: products,
        badge: addedIds.length,
        newProducstIds: addedIds,
      ),
    );
  }

  void _listenToProductChanges() async {
    final idUser = await LocalStorageService.getValue(LocalStorageKeys.idUser);

    _listenerId = RealtimeFirebase.listen('products', (data, _) async {
      final oldProducts = state.products ?? [];
      final oldIds = oldProducts.map((e) => e.id).toSet();

      final raw = Map<String, dynamic>.from(data ?? {});
      final updatedIds = raw.keys.toSet();

      final removedIds = oldIds.difference(updatedIds).toList();

      final updatedProducts = raw.entries.map((entry) {
        final key = entry.key;
        final map = Map<String, dynamic>.from(entry.value);
        return ProductModel.fromJson(key, map);
      }).toList();

      final newIds = updatedProducts
          .where(
            (product) =>
                !oldIds.contains(product.id) && product.vendorId != idUser,
          )
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

  Future<void> addProduct(ProductModel product) async {
    await RealtimeFirebase.create('products', product.toJson());
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

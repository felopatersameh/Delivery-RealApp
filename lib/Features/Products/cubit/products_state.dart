part of 'products_cubit.dart';

@immutable
class ProductsState {
  final List<ProductModel>? products;
  final int badge;
  final List<String>? newProducstIds;
  const ProductsState({
    this.products = const [],
    this.badge = 0,
    this.newProducstIds = const [],
  });

  ProductsState copyWith({
    List<ProductModel>? products,
    int? badge,
    List<String>? newProducstIds,
  }) {
    return ProductsState(
      products: products ?? this.products,
      badge: badge ?? this.badge,
      newProducstIds: newProducstIds ?? this.newProducstIds,
    );
  }
}

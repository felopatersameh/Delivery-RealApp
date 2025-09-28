import 'package:delivery/Features/Products/Model/product_model.dart';

class OrderProduct {


    final ProductModel product;
  final int quantity;

  OrderProduct({required this.product, required this.quantity});
  double get totalPrice => product.price * quantity;

    factory OrderProduct.fromJson(dynamic json) {
    if (json is! Map) return OrderProduct.empty();

    final map = json.map((key, value) => MapEntry(key.toString(), value));

    return OrderProduct(
      product: ProductModel.fromJsonOrder(map['product']),
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  factory OrderProduct.empty() {
    return OrderProduct(product: ProductModel.empty(), quantity: 0);
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  OrderProduct copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return OrderProduct(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }




}

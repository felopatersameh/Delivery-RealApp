class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String photo;
  final int stockQuantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.photo,
    required this.stockQuantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });
  bool get isInStock => stockQuantity > 0;

  factory ProductModel.fromJsonOrder(dynamic json) {
    if (json is! Map) return ProductModel.empty();

    final map = json.map((key, value) => MapEntry(key.toString(), value));

    return ProductModel(
      id: map['id'] ?? '',
      vendorId: map['idAdmin'] ?? '',
      name: map['name'] ?? '',
      photo: map['photo'] ?? '',
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  factory ProductModel.fromJson(dynamic json, Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      vendorId: map['idAdmin'] ?? '',
      name: map['name'] ?? '',
      photo: map['photo'] ?? '',
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      vendorId: '',
      name: '',
      photo: '',
      stockQuantity: 0,
      price: 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idAdmin': vendorId,
      'name': name,
      'photo': photo,
      'stockQuantity': stockQuantity,
      'price': price,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  ProductModel copywith({int? stockQuantity}) {
    return ProductModel(
      id: id,
      vendorId: vendorId,
      name: name,
      photo: photo,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      price: price,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

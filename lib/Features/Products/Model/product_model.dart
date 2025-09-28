
class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String photo;
  final int stockQuantity;
  final double price;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.photo,
    required this.stockQuantity,
    required this.price,
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
    );
  } 
  
 factory  ProductModel.fromJson(dynamic json ,Map<String , dynamic>map ) {
  
    return ProductModel(
      id: map['id'] ?? '',
      vendorId: map['idAdmin'] ?? '',
      name: map['name'] ?? '',
      photo: map['photo'] ?? '',
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
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
    };
  }
}

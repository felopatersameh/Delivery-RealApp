class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String photo;
  final double price;
  final int stockQuantity;

  ProductModel({
    required this.id,
    required this.name,
    required this.photo,
    required this.price,
    required this.vendorId,
    required this.stockQuantity,
  });
  
  bool get isInStock => stockQuantity > 0;

  ProductModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? photo,
    double? price,
    int? stockQuantity,
  }) {
    return ProductModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

factory ProductModel.fromJson(String id, Map<String, dynamic> json) {
  return ProductModel(
    id: id, 
    vendorId: json['idAdmin'],
    name: json['name'],
    photo: json['photo'],
    price: (json['price'] as num).toDouble(), 
    stockQuantity: json['stockQuantity'],
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idAdmin': vendorId,
      'name': name,
      'photo': photo,
      'price': price,
      'stockQuantity': stockQuantity,
    };
  }
}

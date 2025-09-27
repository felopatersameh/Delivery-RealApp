import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Product Model
class Product {
  final String id;
  final String name;
  final String photo;
  final double price;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.photo,
    required this.price,
    required this.stockQuantity,
  });

  bool get isInStock => stockQuantity > 0;
}

// Products Page
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample products data
    final List<Product> products = [
      Product(
        id: '1',
        name: 'iPhone 15 Pro',
        photo: 'https://via.placeholder.com/300x300?text=iPhone+15',
        price: 999.99,
        stockQuantity: 5,
      ),
      Product(
        id: '2',
        name: 'Samsung Galaxy S24',
        photo: 'https://via.placeholder.com/300x300?text=Galaxy+S24',
        price: 849.99,
        stockQuantity: 0,
      ),
      Product(
        id: '3',
        name: 'MacBook Pro',
        photo: 'https://via.placeholder.com/300x300?text=MacBook+Pro',
        price: 1999.99,
        stockQuantity: 3,
      ),
      Product(
        id: '4',
        name: 'iPad Air',
        photo: 'https://via.placeholder.com/300x300?text=iPad+Air',
        price: 599.99,
        stockQuantity: 8,
      ),
      Product(
        id: '5',
        name: 'Apple Watch',
        photo: 'https://via.placeholder.com/300x300?text=Apple+Watch',
        price: 399.99,
        stockQuantity: 12,
      ),
      Product(
        id: '6',
        name: 'AirPods Pro',
        photo: 'https://via.placeholder.com/300x300?text=AirPods+Pro',
        price: 249.99,
        stockQuantity: 0,
      ),
    ];

    return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductItem(
                product: products[index],
                onAddToOrder: (product, quantity) {
                  // Handle add to order
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added $quantity x ${product.name} to order',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
        ),
      
     );
  }
}

// Individual Product Item Widget (StatefulWidget)
class ProductItem extends StatefulWidget {
  final Product product;
  final Function(Product product, int quantity) onAddToOrder;

  const ProductItem({
    super.key,
    required this.product,
    required this.onAddToOrder,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  int selectedQuantity = 1;

  void _incrementQuantity() {
    if (selectedQuantity < widget.product.stockQuantity) {
      setState(() {
        selectedQuantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (selectedQuantity > 1) {
      setState(() {
        selectedQuantity--;
      });
    }
  }

  void _addToOrder() {
    if (widget.product.isInStock) {
      widget.onAddToOrder(widget.product, selectedQuantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 500.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex:3,
            child: Container(
              // height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(  
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
                child: widget.product.photo.isNotEmpty
                    ? Image.network(
                        widget.product.photo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40.sp,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.shopping_bag,
                          size: 40.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
          ),

          // Product Info
          Expanded(
            flex:4,
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            
                  SizedBox(height: 4.h),
            
                  // Price
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
            
                  SizedBox(height: 4.h),
            
                  // Stock Status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.product.isInStock
                          ? Colors.green.withValues(alpha:0.1)
                          : Colors.red.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      widget.product.isInStock
                          ? 'In Stock (${widget.product.stockQuantity})'
                          : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: widget.product.isInStock
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
            
                  SizedBox(height: 8.h),
            
                  // Quantity Selector
                  if (widget.product.isInStock) ...[
                    Row(
                      children: [
                        Text(
                          'Qty:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          height: 30.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: _decrementQuantity,
                                child: SizedBox(
                                  width: 30.w,
                                  height: 30.h,
                                  child: Icon(
                                    Icons.remove,
                                    size: 16.sp,
                                    color: selectedQuantity > 1
                                        ? Colors.blue
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              Container(
                                width: 40.w,
                                height: 30.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '$selectedQuantity',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _incrementQuantity,
                                child: SizedBox(
                                  width: 30.w,
                                  height: 30.h,
                                  child: Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: selectedQuantity <
                                            widget.product.stockQuantity
                                        ? Colors.blue
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            
                    SizedBox(height: 8.h),
            
                    // Add to Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 32.h,
                      child: ElevatedButton(
                        onPressed: _addToOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Add to Order',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Out of Stock Button
                    SizedBox(
                      width: double.infinity,
                      height: 32.h,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
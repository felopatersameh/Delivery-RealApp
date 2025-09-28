import 'package:delivery/Features/Products/Model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductItem extends StatefulWidget {
  final ProductModel product;
  final String? currentUserId; // Current user ID to check ownership
  final Function(ProductModel product, int quantity)? onAddToOrder;
  final Function(String productId)?
  onDelete; // Delete callback returns product ID
  final Function(ProductModel product)?
  onEdit; // Edit callback returns full product data

  const ProductItem({
    super.key,
    required this.product,
    this.currentUserId,
    this.onAddToOrder,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  int selectedQuantity = 1;

  // Check if current user is the owner of this product
  bool get isOwner =>
      widget.currentUserId != null &&
      widget.currentUserId == widget.product.vendorId;

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
    if (widget.product.isInStock && widget.onAddToOrder != null) {
      widget.onAddToOrder!(widget.product, selectedQuantity);
    }
  }

  void _editProduct() {
    if (widget.onEdit != null) {
      widget.onEdit!(widget.product);
    }
  }

  void _deleteProduct() async{
    // Show confirmation dialog
   await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Product',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.product.name}"?',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async{
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                await widget.onDelete!(widget.product.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Owner Badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 250.h,
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
        
                  // Owner Badge
                  if (isOwner)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12.sp, color: Colors.white),
                            SizedBox(width: 2.w),
                            Text(
                              'My Product',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        
            // Product Info
            Expanded(
              flex: 5,
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
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
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
        
                    // Action Buttons Section
                    if (isOwner) ...[
                      // Owner Controls (Edit & Delete)
                      Row(
                        children: [
                          // Edit Button
                          Expanded(
                            child: SizedBox(
                              height: 32.h,
                              child: ElevatedButton.icon(
                                onPressed: _editProduct,
                                icon: Icon(Icons.edit, size: 14.sp),
                                label: Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Delete Button
                          Expanded(
                            child: SizedBox(
                              height: 32.h,
                              child: ElevatedButton.icon(
                                onPressed: _deleteProduct,
                                icon: Icon(Icons.delete, size: 14.sp),
                                label: Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (widget.product.isInStock) ...[
                      // Customer Controls (Quantity & Add to Order)
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
                                      color:
                                          selectedQuantity <
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
                      // Out of Stock - Show message
                      Container(
                        width: double.infinity,
                        height: 32.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6.r),
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
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Features/Orders/Cubit/order_cubit.dart';
import 'package:delivery/Features/Orders/Models/order_model.dart';
import 'package:delivery/Features/Orders/Models/order_product.dart';
import 'package:delivery/Features/Products/Model/product_model.dart';
import 'package:delivery/Features/Products/Widgets/product_item.dart';
import 'package:delivery/Features/Products/cubit/products_cubit.dart';
import 'package:delivery/Features/Profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Orders/Models/order_manager.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<String>? newProducts = [];
  @override
  void initState() {
    super.initState();
    // Initialize ProfileCubit when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newProducts = context.read<ProductsCubit>().state.newProducstIds ?? [];
      context.read<ProductsCubit>().resetBadge();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<ProfileCubit>().state.me;
    final isVendor = user!.userType == UserType.vendor;
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final cubit = context.read<ProductsCubit>();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 160.w / (isVendor?250: 320).h,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: state.products?.length,
              itemBuilder: (context, index) {
                final bool isNew =
                    newProducts != null &&
                    newProducts!.contains(state.products?[index].id);
                return Container(
                  decoration: isNew
                      ? BoxDecoration(
                          border: Border.all(width: 2.w, color: Colors.green),
                          borderRadius: BorderRadius.circular(12.r),
                        )
                      : null,
                  child: ProductItem(
                    product: state.products![index],
                    onAddToOrder: (product, quantity) async {
                      if (quantity > product.stockQuantity) return;
                      bool added = await context
                          .read<OrdersCubit>()
                          .handleProductAdd(product, quantity);

                      if (!added) {
                        final order = OrderManager.createOrder(
                          products: [
                            OrderProduct(product: product, quantity: quantity),
                          ],
                          client: user,
                          vendorId: product.vendorId,
                        );
                        if (!context.mounted) return;
                        context.read<OrdersCubit>().createOrder(order);
                      }
                      ProductModel editProductQuantity = product.copywith(
                        stockQuantity: product.stockQuantity - quantity,
                      );
                      if (!context.mounted) return;
                      context.read<ProductsCubit>().updateProduct(
                        product.id,
                        editProductQuantity.toJson(),
                      );
                    },
                    currentUserId: user!.id,
                    onDelete: (id) {
                      cubit.deleteProduct(id);
                    },
                    onEdit: (product) {
                      _showUpdateProductBottomSheet(context, user.id, product);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showUpdateProductBottomSheet(
  BuildContext context,
  String id,
  ProductModel model,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddProductBottomSheet(
      productToEdit: model,
      onProductAdded: (newProduct) {
        context.read<ProductsCubit>().updateProduct(
          newProduct.id,
          newProduct.toJson(),
        );
      },
      currentUserId: id,
    ),
  );
}

class AddProductBottomSheet extends StatefulWidget {
  final Function(ProductModel) onProductAdded;
  final String currentUserId;
  final ProductModel? productToEdit;
  const AddProductBottomSheet({
    super.key,
    required this.onProductAdded,
    required this.currentUserId,
    this.productToEdit,
  });

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _photoController = TextEditingController();

  bool _isLoading = false;

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final p = widget.productToEdit!;
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _stockController.text = p.stockQuantity.toString();
      _photoController.text = p.photo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate delay
    final now = DateTime.now();
    final updatedProduct = ProductModel(
      createdAt: widget.productToEdit?.createdAt ?? now,
      updatedAt: now,
      id: isEditing
          ? widget.productToEdit!.id
          : now.millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      photo: _photoController.text.trim(),
      price: double.parse(_priceController.text),
      stockQuantity: int.parse(_stockController.text),
      vendorId: widget.currentUserId,
    );

    widget.onProductAdded(updatedProduct);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 10.h),
            width: 50.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(
                  Icons.add_shopping_cart,
                  size: 24.sp,
                  color: Colors.blue.shade600,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Add New Product',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Name
                    Text(
                      'Product Name',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter product name',
                        prefixIcon: const Icon(Icons.shopping_bag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Price
                    Text(
                      'Price (\$)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Stock Quantity
                    Text(
                      'Stock Quantity',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixIcon: const Icon(Icons.inventory),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Stock quantity is required';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock < 0) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Photo URL
                    Text(
                      'Photo URL',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _photoController,
                      decoration: InputDecoration(
                        hintText: 'https://example.com/image.jpg',
                        prefixIcon: const Icon(Icons.image),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Photo URL is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 30.h),

                    // Add Product Button
                    SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Adding Product...',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Add Product',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

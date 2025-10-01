import 'package:delivery/Core/Functions/show_update_product_bottom_sheet.dart';

import '../../Core/Enum/message_type.dart';
import '../../Core/Enum/user_type.dart';
import '../../Core/Functions/show_message_snack_bar.dart';
import '../Orders/Cubit/order_cubit.dart';
import 'Model/product_model.dart';
import 'Widgets/product_item.dart';
import 'cubit/products_cubit.dart';
import '../Profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Orders/Models/order_manager.dart';
import '../Orders/Models/order_product.dart';

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
                childAspectRatio: 160.w / (isVendor ? 250 : 320).h,
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
                      if (quantity > product.stockQuantity) {
                        showMessageSnackBar(
                          context,
                          title: "Avalible in Stock is ${product.stockQuantity}",
                          type: MessageType.error,
                        );
                        return;
                      }
                      bool added = await context
                          .read<OrdersCubit>()
                          .handleProductAdd(product, quantity);
                      //* create New order
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
                        showMessageSnackBar(
                          context,
                          title: "Created Order SuccessFully",
                          type: MessageType.success,
                        );
                      }
                      //* update Product Quantity
                      ProductModel editProductQuantity = product.copywith(
                        stockQuantity: product.stockQuantity - quantity,
                      );
                      if (!context.mounted) return;
                      context.read<ProductsCubit>().updateProduct(
                        product.id,
                        editProductQuantity.toJson(),
                      );
                      showMessageSnackBar(
                        context,
                        title: "Adedd ${product.name} in Order",
                        type: MessageType.success,
                      );
                    },
                    currentUserId: user.id,
                    onDelete: (item) async {
                      await showMessageSnackBar(
                        context,
                        title: "Deleting",
                        type: MessageType.loading,
                        onLoading: () async =>
                            await cubit.deleteProduct(item.id),
                      );
                      if (!context.mounted) return;
                      showMessageSnackBar(
                        context,
                        title: "Deleted ${item.name} SuccessFully",
                        type: MessageType.success,
                      );
                    },
                    onEdit: (product) async {
                      await showMessageSnackBar(
                        context,
                        title: "Updatting",
                        type: MessageType.loading,
                        onLoading: () async =>
                            await showUpdateProductBottomSheet(
                              context,
                              user.id,
                              product,
                            ),
                      );
                      if (!context.mounted) return;

                      showMessageSnackBar(
                        context,
                        title: "Updated ${product.name} SuccessFully",
                        type: MessageType.success,
                      );
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

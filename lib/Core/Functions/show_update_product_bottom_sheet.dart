import 'package:delivery/Features/Products/Model/product_model.dart';
import 'package:delivery/Features/Products/Widgets/add_product_bottom_sheet.dart';
import 'package:delivery/Features/Products/cubit/products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showUpdateProductBottomSheet(
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

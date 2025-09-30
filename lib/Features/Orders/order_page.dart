import 'dart:developer';

import 'package:delivery/Features/Orders/Widgets/empty_orders_widget.dart';
import 'package:delivery/Features/Orders/Widgets/order_invoice.dart';
import 'package:delivery/Features/Profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Core/Enum/order_status.dart';
import 'Cubit/order_cubit.dart';
import 'Cubit/order_state.dart';
import 'Models/order_model.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.orders == null || state.orders!.isEmpty) {
            return EmptyOrdersWidget();
          }

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: ListView.builder(
              itemCount: state.orders!.length,
              itemBuilder: (context, index) {
                final order = state.orders![index];
                final isNew = state.newOrderIds.contains(order.orderID);

                return OrderInvoice(
                  currentUser: context.read<OrdersCubit>().currentUserType!,
                  idCurent: context.read<OrdersCubit>().currentUserId!,
                  order: order,
                  isNew: isNew,
                  allowedActions: context
                      .read<OrdersCubit>()
                      .getAllowedActionsForOrder(order),
                  onActionTap: (action) async =>
                      await _handleOrderAction(context, order, action),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleOrderAction(
    BuildContext context,
    OrderModel order,
    String action,
  ) async {
    final cubit = context.read<OrdersCubit>();
    final me = context.read<ProfileCubit>().state.me!;

    switch (action) {
      case 'Cancel Order':
        _showCancelDialog(context, order);
        break;
      case 'Accept Order':
        cubit.updateOrderStatus(order.orderID, OrderStatus.searching);
        break;
      case 'Reject Order':
        _showRejectDialog(context, order);
        break;
      case 'Accept Delivery':
        OrderDialogs.showLoading(context);
        await cubit.updateOrderStatus(
          order.orderID,
          OrderStatus.running,
          deliveryPerson: me,
        );
        if (!context.mounted) return;
        OrderDialogs.hideLoading(context);
        break;
      case 'Mark as Delivered':
      case 'Mark as Received':
      bool code =  await OrderDialogs.verifyCodeDialog(
          context: context,
           expected: order.numberOrderFinish.toString()
        );
        if(code) {
          await cubit.updateOrderStatus(order.orderID, OrderStatus.finished);
        }
        break;
    }
  }

  void _showCancelDialog(BuildContext context, OrderModel order) async {
    final confirmed = await OrderDialogs.confirmDialog(
      context: context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order ${order.orderID}?',
      confirmText: 'Yes, Cancel',
      confirmColor: Colors.red,
    );

    if (confirmed && context.mounted) {
      context.read<OrdersCubit>().updateOrderStatus(
        order.orderID,
        OrderStatus.removed,
      );
    }
  }

  void _showRejectDialog(BuildContext context, OrderModel order) async {
    final reason = await OrderDialogs.inputReasonDialog(
      context: context,
      title: 'Reject Order ${order.orderID}',
      hint: 'Please provide a reason for rejection:',
      confirmText: 'Reject',
      confirmColor: Colors.red,
    );

    if (reason != null && reason.isNotEmpty && context.mounted) {
      context.read<OrdersCubit>().updateOrderStatus(
        order.orderID,
        OrderStatus.rejected,
        reason: reason,
      );
    }
  }
}

class OrderDialogs {
  static Future<bool> confirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<String?> inputReasonDialog({
    required BuildContext context,
    required String title,
    required String hint,
    String confirmText = 'Submit',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
  }) async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hint),
            SizedBox(height: 16.h),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> showLoading(
    BuildContext context, {
    String message = 'Please wait...',
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // ما يتقفلش بالضغط خارج
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(width: 20.w),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> hideLoading(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<bool> verifyCodeDialog({
    required BuildContext context,
    required String expected,
    String title = 'Enter Code',
    String hint = 'Type the code here',
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final controller = TextEditingController();

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              final input = controller.text.trim();
              if (input.isEmpty || input != expected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code is not correct')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}

import '../../Core/Functions/order_dialogs.dart';
import 'Widgets/empty_orders_widget.dart';
import 'Widgets/order_invoice.dart';
import '../Profile/cubit/profile_cubit.dart';
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
        await cubit.updateOrderStatus(
          order.orderID,
          OrderStatus.running,
          deliveryPerson: me,
        );
        if (!context.mounted) return;
        break;
      case 'Mark as Delivered':
      case 'Mark as Received':
        bool code = await OrderDialogs.verifyCodeDialog(
          context: context,
          expected: order.numberOrderFinish.toString(),
        );
        if (code) {
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

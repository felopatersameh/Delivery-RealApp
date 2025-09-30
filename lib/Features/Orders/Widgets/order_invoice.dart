import 'dart:async';

import '../../../Core/Enum/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Core/Enum/order_status.dart';
import '../Models/order_model.dart';
import '../Models/order_product.dart';

class OrderInvoice extends StatefulWidget {
  final UserType currentUser;
  final String idCurent;
  final OrderModel order;
  final bool isNew;
  final List<String> allowedActions;
  final Function(String action) onActionTap;

  const OrderInvoice({
    super.key,
    required this.order,
    required this.idCurent,
    required this.currentUser,
    required this.isNew,
    required this.allowedActions,
    required this.onActionTap,
  });

  @override
  State<OrderInvoice> createState() => _OrderInvoiceState();
}

class _OrderInvoiceState extends State<OrderInvoice> {
  bool _expanded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will rebuild the widget with updated time
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'Cancel Order':
      case 'Reject Order':
        return Colors.red.shade600;
      case 'Accept Order':
      case 'Accept Delivery':
        return Colors.green.shade600;
      case 'Mark as Delivered':
      case 'Mark as Received':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'Cancel Order':
        return Icons.cancel;
      case 'Reject Order':
        return Icons.close;
      case 'Accept Order':
        return Icons.check_circle;
      case 'Accept Delivery':
        return Icons.delivery_dining;
      case 'Mark as Delivered':
        return Icons.done_all;
      case 'Mark as Received':
        return Icons.thumb_up;
      default:
        return Icons.touch_app;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isClient = order.client.id == widget.idCurent;
    final isvendor = order.vendorId == widget.idCurent;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.isNew ? Colors.orange.shade400 : Colors.grey.shade200,
          width: widget.isNew ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isNew
                ? Colors.orange.withValues(alpha: .15)
                : Colors.grey.withValues(alpha: 0.08),
            spreadRadius: widget.isNew ? 3 : 1,
            blurRadius: widget.isNew ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isNew
                    ? [Colors.orange.shade50, Colors.orange.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
            ),
            child: Column(
              children: [
                if (widget.isNew) ...[
                  Align(
                    alignment: AlignmentGeometry.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade600, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_new,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],

                // Invoice number and NEW badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 16.sp,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'INVOICE',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      child: Align(
                        alignment: AlignmentGeometry.centerRight,
                        child: Text(
                          '#${order.shortId}',
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Order Status Display
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: order.status.color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: order.status.color,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: order.status.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          order.status.icon,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Status',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              order.status.displayName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: order.status.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (order.status.isActive)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: order.status.color,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${(order.statusProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Progress Bar for Active Orders
                if (order.status.isActive) ...[
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: order.statusProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        order.status.color,
                      ),
                      minHeight: 8.h,
                    ),
                  ),
                ],

                SizedBox(height: 12.h),

                // Date, Customer Name, Phone in one line
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatTimeAgo(order.createdAt),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        order.client.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        order.client.phone,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display first product
                if (order.products.isNotEmpty) ...[
                  _buildProductItem(order.products[0]),
                ],

                // Show More button if more than 1 product
                if (order.products.length > 1) ...[
                  SizedBox(height: 10.h),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      icon: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20.sp,
                      ),
                      label: Text(
                        _expanded
                            ? 'Show Less'
                            : 'Show More (${order.products.length - 1})',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                // Rest of products when expanded
                if (_expanded)
                  ...order.products
                      .skip(1)
                      .map(
                        (prod) => Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: _buildProductItem(prod),
                        ),
                      ),

                SizedBox(height: 16.h),

                // Delivery Info (if assigned)
                if (order.delivery.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade600,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.delivery_dining,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Person',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                order.delivery.name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade900,
                                ),
                              ),
                              if (order.delivery.phone.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14.sp,
                                      color: Colors.purple.shade700,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      order.delivery.phone,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.purple.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Rejection Reason (if exists)
                if (order.rejectionReason != null &&
                    order.rejectionReason!.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.cancel,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rejection Reason',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                order.rejectionReason!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.red.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Notes (if exists)
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.note,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                order.notes!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.amber.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Total Amount and Actions in one box
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL AMOUNT',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '\$${order.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (isClient || isvendor) ...[
                        SizedBox(height: 16.h),
                        if (order.numberOrderFinish != null &&
                            order.numberOrderFinish?.isNotEmpty == true &&
                            order.status == OrderStatus.running)
                          Column(
                            children: [
                              Text(
                                'Order Finish Code',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                  ),
                                ),
                                child: Text(
                                  order.numberOrderFinish!,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                      // Action Buttons
                      if (widget.allowedActions.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          alignment: WrapAlignment.center,
                          children: widget.allowedActions.map((action) {
                            final color = _getActionColor(action);
                            final icon = _getActionIcon(action);
                            return SizedBox(
                              height: 44.h,
                              child: ElevatedButton(
                                onPressed: () => widget.onActionTap(action),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  elevation: 3,
                                  shadowColor: color.withValues(alpha: 0.4),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 10.h,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, size: 18.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      action,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderProduct orderProduct) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image with quantity badge
          Stack(
            children: [
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: orderProduct.product.photo.isNotEmpty
                      ? Image.network(
                          orderProduct.product.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 28.sp,
                                color: Colors.grey.shade500,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.shopping_bag,
                            size: 28.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${orderProduct.quantity}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 14.w),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderProduct.product.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  '\$${orderProduct.product.price.toStringAsFixed(2)} × ${orderProduct.quantity}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      'Subtotal: ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${orderProduct.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

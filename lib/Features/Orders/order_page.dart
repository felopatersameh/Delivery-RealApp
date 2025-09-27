import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// User Type Enum
enum UserType { client, admin, vendor }

// Order Status Enum
enum OrderStatus {
  pending,
  accepted,
  done,
  rejected,
  cancelled, // Added cancelled status for clients
}

// Order Model
class Order {
  final String id;
  final String productName;
  final String productPhoto;
  final int quantity;
  final double price;
  final String? userEmail;
  final String? userName;
  final String? userPhone;
  OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.productName,
    required this.productPhoto,
    required this.quantity,
    required this.price,
    this.userEmail,
    this.userName,
    this.userPhone,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  String get shortId => id.substring(0, 8);

  String get displayContact {
    // if (userEmail != null && userEmail!.isNotEmpty) {
    //   return userEmail!;
    // } else if (userName != null && userName!.isNotEmpty) {
    return userName!;
    // } else if (userPhone != null && userPhone!.isNotEmpty) {
    //   return userPhone!;
    // }
    // return 'No contact info';
  }

  double get totalPrice => price * quantity;

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.done:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.done:
        return 'Done';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderPage extends StatefulWidget {
  final UserType userType;

  OrderPage({Key? key, this.userType = UserType.client}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _loadSampleOrders();
  }

  void _loadSampleOrders() {
    orders = [
      Order(
        id: 'ORD_12345678901',
        productName: 'iPhone 15 Pro Max 256GB',
        productPhoto: 'https://via.placeholder.com/300x300?text=iPhone+15',
        quantity: 2,
        price: 999.99,
        userEmail: 'john.doe@example.com',
        userName: 'John Doe',
        userPhone: '+1234567890',
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Order(
        id: 'ORD_98765432101',
        productName: 'Samsung Galaxy S24 Ultra',
        productPhoto: 'https://via.placeholder.com/300x300?text=Galaxy+S24',
        quantity: 1,
        price: 849.99,
        userEmail: null,
        userName: 'Jane Smith',
        userPhone: '+0987654321',
        status: OrderStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Order(
        id: 'ORD_55566677701',
        productName: 'MacBook Pro 14-inch M3',
        productPhoto: 'https://via.placeholder.com/300x300?text=MacBook+Pro',
        quantity: 1,
        price: 1999.99,
        userEmail: 'mike.wilson@example.com',
        userName: "wilson",
        userPhone: null,
        status: OrderStatus.done,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'ORD_11122233301',
        productName: 'iPad Air 5th Generation',
        productPhoto: 'https://via.placeholder.com/300x300?text=iPad+Air',
        quantity: 3,
        price: 599.99,
        userEmail: "",
        userName: "miky",
        userPhone: '+1122334455',
        status: OrderStatus.rejected,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return OrderInvoice(
                order: orders[index],
                userType: UserType.client,
                onStatusChanged: (newStatus) {
                  setState(() {
                    orders[index].status = newStatus;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Order ${orders[index].shortId} status changed to ${newStatus.name}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      backgroundColor: orders[index].statusColor,
                    ),
                  );
                },
              );
            },
          ),
        ),
      )
    ;
  }
}

// Invoice-Style Order Item Widget
class OrderInvoice extends StatefulWidget {
  final Order order;
  final UserType userType;
  final Function(OrderStatus) onStatusChanged;

  const OrderInvoice({
    super.key,
    required this.order,
    required this.userType,
    required this.onStatusChanged,
  });

  @override
  State<OrderInvoice> createState() => _OrderInvoiceState();
}

class _OrderInvoiceState extends State<OrderInvoice> {
  void _showStatusDialog() {
    List<OrderStatus> availableStatuses = _getAvailableStatuses();

    if (availableStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No status changes available for this order',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            widget.userType == UserType.client
                ? 'Cancel Order'
                : 'Change Status',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableStatuses.map((status) {
              return ListTile(
                leading: Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  _getStatusText(status),
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onStatusChanged(status);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<OrderStatus> _getAvailableStatuses() {
    if (widget.userType == UserType.client) {
      // Clients can only cancel pending orders
      if (widget.order.status == OrderStatus.pending) {
        return [OrderStatus.cancelled];
      }
      return [];
    } else {
      // Admin/Vendor can change to any status except cancelled
      return [
        OrderStatus.pending,
        OrderStatus.accepted,
        OrderStatus.done,
        OrderStatus.rejected,
      ];
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.done:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.done:
        return 'Done';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _canChangeStatus() {
    if (widget.userType == UserType.client) {
      return widget.order.status == OrderStatus.pending;
    }
    return widget.order.status != OrderStatus.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Invoice Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVOICE',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '#${widget.order.shortId}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _canChangeStatus() ? _showStatusDialog : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: widget.order.statusColor,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: widget.order.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          widget.order.statusText,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.order.statusColor,
                          ),
                        ),
                        if (_canChangeStatus()) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.edit,
                            size: 14.sp,
                            color: widget.order.statusColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Invoice Body
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Date and Customer Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatDateTime(widget.order.createdAt),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Customer:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.order.displayContact,

                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Product Item Box
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: widget.order.productPhoto.isNotEmpty
                              ? Image.network(
                                  widget.order.productPhoto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 24.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.shopping_bag,
                                    size: 24.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.productName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty: ${widget.order.quantity}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '\$${widget.order.price.toStringAsFixed(2)} each',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Total Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL AMOUNT',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '\$${widget.order.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
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
}

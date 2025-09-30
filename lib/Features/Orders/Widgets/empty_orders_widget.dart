import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyOrdersWidget extends StatelessWidget {
  const EmptyOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'No orders found',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? backGround;

  const ProfileCard({
    super.key,
    required this.icon,
    required this.title,
    this.backGround = Colors.white,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final checkValue = value?.isNotEmpty == true && value != "";
    return Container(
      padding: const EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: backGround,
        borderRadius: BorderRadius.circular(12).r,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12).r,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10).r,
            ),
            child: Icon(icon, color: Colors.blue, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (checkValue) ...[
                  SizedBox(height: 4.h),
                  Text(
                    value ?? "",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

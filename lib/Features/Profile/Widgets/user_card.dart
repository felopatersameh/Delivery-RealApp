import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Features/Profile/Model/user_modell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserCard extends StatelessWidget {
  final UserModell user;
  final UserType currentUserType;
  final Function(UserModell) onUserTap;

  const UserCard({
    super.key,
    required this.user,
    required this.currentUserType,
    required this.onUserTap,
  });

String _formatJoinDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays < 1) {
    return 'Joined today';
  } else if (difference.inDays < 7) {
    return 'Joined ${difference.inDays}d ago';
  } else {
    return 'Joined ${date.day}/${date.month}/${date.year}';
  }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onUserTap(user),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // User Avatar
                Container(
                  width: 55.w,
                  height: 55.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: user.typeColor, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 25.r,
                    backgroundColor: user.typeColor,
                    backgroundImage:
                        user.photo != null && user.photo!.isNotEmpty
                        ? NetworkImage(user.photo!)
                        : null,
                    child: user.photo == null || user.photo!.isEmpty
                        ? Icon(user.typeIcon, size: 24.sp, color: Colors.white)
                        : null,
                  ),
                ),

                SizedBox(width: 16.w),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!user.isActive)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'Inactive',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Email
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // User Type (always show)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: user.typeColor.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                user.typeText,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: user.typeColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Phone and Join Date (only for non-client users)
                      if (currentUserType != UserType.client) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            ...[
                            Icon(
                              Icons.phone,
                              size: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                user.phone,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ]
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatJoinDate(user.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Features/Profile/Model/user_modell.dart';
import 'package:delivery/Features/Profile/Widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlphabeticalUserList extends StatelessWidget {
  final List<UserModell> filteredUsers;
  final List<String>? newUSers;
  final UserType currentUserType;
  final void Function(UserModell) onUserTap;
  final Map<String, List<UserModell>> Function(List<UserModell>, bool)
  groupUsersByLetter;

  const AlphabeticalUserList({
    super.key,
    required this.filteredUsers,
    required this.currentUserType,
    required this.onUserTap,
    required this.groupUsersByLetter,
    required this.newUSers,
  });

  @override
  Widget build(BuildContext context) {
    bool clientOnly = (currentUserType == UserType.client);

    Map<String, List<UserModell>> groupedUsers = groupUsersByLetter(
      filteredUsers,
      clientOnly,
    );

    if (groupedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No users to display',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: groupedUsers.length,
      itemBuilder: (context, sectionIndex) {
        String letter = groupedUsers.keys.elementAt(sectionIndex);
        List<UserModell> usersInSection = groupedUsers[letter]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alphabet Header
            Container(
              margin: EdgeInsets.only(
                top: sectionIndex == 0 ? 0 : 20.h,
                bottom: 12.h,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '${usersInSection.length} user${usersInSection.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Users in this section
            ...usersInSection.map((user) {
              final isNew = newUSers?.contains(user.id) ?? false;

              return Container(
                decoration: isNew
                    ? BoxDecoration(
                        border: Border.all(width: 2.w, color: Colors.green),
                        borderRadius: BorderRadius.circular(12.r),
                      )
                    : null,
                child: UserCard(
                  user: user,
                  currentUserType: currentUserType,
                  onUserTap: onUserTap,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

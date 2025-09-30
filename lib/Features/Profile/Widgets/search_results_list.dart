import '../../../Core/Enum/user_type.dart';
import '../Model/user_modell.dart';
import 'user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchResultsList extends StatelessWidget {
  final List<UserModell> filteredUsers;
  final UserType currentUserType;
  final String idUser;
  final void Function(UserModell) onUserTap;

  const SearchResultsList({
    super.key,
    required this.filteredUsers,
    required this.currentUserType,
    required this.idUser,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var user = filteredUsers[index];

        // Hide non-client users for client users
        if (currentUserType == UserType.client &&
                user.userType != UserType.client ||
            idUser == user.id) {
          return const SizedBox.shrink();
        }

        return UserCard(
          user: user,
          currentUserType: currentUserType,
          onUserTap: onUserTap,
        );
      },
    );
  }
}

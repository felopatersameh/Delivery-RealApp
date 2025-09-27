import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Core/Local/local_storage.dart';
import 'package:delivery/Features/Profile/Widgets/photo_user.dart';
import 'package:delivery/Features/Profile/Widgets/profile_card.dart';
import 'package:delivery/Features/Profile/cubit/profile_cubit.dart';
import 'package:delivery/Features/Splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final name = state.me?.name ?? 'a';
        final email = state.me?.email ?? "";
        final password = state.me?.password ?? "";
        final photo = "";
        final userType =
            state.me?.userType.displayName ?? UserType.client.displayName;
        final userID = "_${state.me?.id}";
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 20.h,
              children: [
                PhotoUser(photo: photo, name: name),

                SizedBox(height: 10.h),
                ProfileCard(
                  icon: Icons.fingerprint,
                  title: 'User ID',
                  value: userID,
                ),

                ProfileCard(icon: Icons.person, title: 'Name', value: name),

                ProfileCard(icon: Icons.email, title: 'Email', value: email),

                ProfileCard(
                  icon: Icons.password,
                  title: 'Password',
                  value: password,
                ),

                ProfileCard(
                  icon: Icons.badge,
                  title: 'Type Account',
                  value: userType,
                ),
                ProfileCard(
                  icon: Icons.password,
                  title: 'Password',
                  value: password,
                ),
                InkWell(
                  onTap: () async {
                    final response = await showCustomDialog(
                      context: context,
                      icon: Icons.logout_rounded,
                      title: "Log out",
                      description: "",
                      iconColor: Colors.red,
                    );

                    if (response && context.mounted) {
                    await  LocalStorageService.clear();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => SplashApp()),
                        (route) => false,
                      );
                      }
                    }
                  },
                  child: ProfileCard(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    backGround: Colors.redAccent[100],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<bool> showCustomDialog({
  required BuildContext context,
  required String title,
  required String description,
  IconData? icon,
  Color iconColor = Colors.blue,
}) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(20.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 48.w, color: iconColor),
            if (icon != null) SizedBox(height: 12.h),

            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  ).then((value) => value ?? false);
}

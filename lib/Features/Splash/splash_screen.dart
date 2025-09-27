import 'dart:async';

import 'package:delivery/Core/Local/local_storage.dart';
import 'package:delivery/Core/Local/local_storage_keys.dart';
import 'package:delivery/Features/Profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Main/main_screen.dart';
import 'auth_page.dart';

class SplashApp extends StatefulWidget {
  const SplashApp({super.key});

  @override
  State<SplashApp> createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  final StreamController<double> _progressStreamController =
      StreamController.broadcast();
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
    );

    // Create progress animation
    _progressAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        )..addListener(() {
          _progressStreamController.add(_progressAnimation.value);
        });

    _navigateToMainScreen();
  }

  Future<void> _navigateToMainScreen() async {
    _animationController.value = 0.1;
    bool passed = true;
    _animationController.value = 0.2;
    final String tokenFCM = await LocalStorageService.getValue(
      LocalStorageKeys.tokenFCM,
      defaultValue: "",
    );
    _animationController.value = 0.3;
    final String id = await LocalStorageService.getValue(
      LocalStorageKeys.idUser,
      defaultValue: "",
    );
    _animationController.value = 0.4;
    if (id.isEmpty || id == "" ||  tokenFCM.isEmpty || tokenFCM == "") {
      if (mounted) {
        passed = await showAuthDialog(context);
      }
    }
    if (passed && mounted) {
      _animationController.value = 0.5;
      await context.read<ProfileCubit>().init(); //* 2
      _animationController.value = 0.6;
      _animationController.value = 0.7;
      _animationController.value = 0.8;
      _animationController.value = 0.9;
      _animationController.value = 1.0;
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
    _animationController.value = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, 
      body: Center(
        child: StreamBuilder<double>(
          stream: _progressStreamController.stream,
          initialData: 1.0,
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0.0;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo or Icon (optional)
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flutter_dash, // Replace with your app icon
                    size: 60.w,
                    color: Colors.blue.shade700,
                  ),
                ),

                SizedBox(height: 40.h),

                // Loading text
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 30.h),

                // Animated progress bar
                Container(
                  width: 250.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.grey.shade300,
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Container(
                            width: (250 * _progressAnimation.value).w,
                            height: (6).h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                  Colors.blue.shade800,
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Progress percentage (optional)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),

                SizedBox(height: 60.h),
                if (progress == 0.0) ...[
                  SizedBox(height: 60.h),
                  TextButton(
                    onPressed: () => _navigateToMainScreen(),
                    child: const Text("Try Again"),
                  ),
                ],
                if (progress > 0.2)
                  Text(
                    'Welcome to Your App',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

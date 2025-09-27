import 'package:bloc/bloc.dart';
import 'package:delivery/Features/Orders/order_page.dart';
import 'package:delivery/Features/Profile/cubit/profile_cubit.dart';
import 'package:delivery/Features/Profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Products/products.page.dart';
import '../../Profile/users_page.dart';
import '../main_screen.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState());

  List<BottomNavigationBarItem> bottomNavigationBarItem(BuildContext context) {
    final profile = context.read<ProfileCubit>().state;
    return [
      BottomNavigationBarItem(
        icon: bottomNavIconWithBadge(5, Icons.shopping_basket_rounded),
        label: "Orders",
      ),

      BottomNavigationBarItem(
        icon:  bottomNavIconWithBadge(5, Icons.store_rounded),
        label: "Products",
      ),

      BottomNavigationBarItem(
        icon:bottomNavIconWithBadge(0, Icons.person_2_rounded) ,
        label: "Profile",
      ),

      BottomNavigationBarItem(
        icon: bottomNavIconWithBadge(profile.badge, Icons.group_add_rounded),
        label: "Users",
      ),
    ];
  }

  List<Widget> screens = [
    OrderPage(),
    ProductsPage(),
    ProfilePage(),
    UsersPage(),
  ];

  List<String> nameScreens = [
    "Orders",
    "Products",
    "Profile",
    "Users Management",
  ];

  void changeIndex(int index) => emit(state.copyWith(index: index));
}

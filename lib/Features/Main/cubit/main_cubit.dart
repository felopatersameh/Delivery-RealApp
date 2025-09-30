import '../../Orders/Cubit/order_cubit.dart';
import '../../Orders/order_page.dart';
import '../../Products/cubit/products_cubit.dart';
import '../../Profile/cubit/profile_cubit.dart';
import '../../Profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Core/Enum/user_type.dart';
import '../../Products/products.page.dart';
import '../../Profile/users_page.dart';
import '../main_screen.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState());
  bool typeCheck = false;
  List<BottomNavigationBarItem> bottomNavigationBarItem(BuildContext context) {
    final profile = context.read<ProfileCubit>().state;
    typeCheck = profile.me!.userType != UserType.delivery;
    final product = context.read<ProductsCubit>().state;
    final orders = context.read<OrdersCubit>().state;
    return [
      BottomNavigationBarItem(
        icon: bottomNavIconWithBadge(
          orders.badge,
          Icons.shopping_basket_rounded,
        ),
        label: "Orders",
      ),
      if (typeCheck)
        BottomNavigationBarItem(
          icon: bottomNavIconWithBadge(product.badge, Icons.store_rounded),
          label: "Products",
        ),

      BottomNavigationBarItem(
        icon: bottomNavIconWithBadge(0, Icons.person_2_rounded),
        label: "Profile",
      ),

      BottomNavigationBarItem(
        icon: bottomNavIconWithBadge(profile.badge, Icons.group_add_rounded),
        label: "Users",
      ),
    ];
  }

  List<Widget> get screens => [
    OrdersPage(),
    if (typeCheck) ProductsPage(),
    ProfilePage(),
    UsersPage(),
  ];

  List<String> get nameScreens => [
    "Orders",
    if (typeCheck) "Products",
    "Profile",
    "Users Management",
  ];

  void changeIndex(int index) => emit(state.copyWith(index: index));
}

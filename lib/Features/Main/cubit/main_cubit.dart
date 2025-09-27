import 'package:bloc/bloc.dart';
import 'package:delivery/Features/Orders/order_page.dart';
import 'package:delivery/Features/Profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../Products/products.page.dart';
import '../../Profile/users_page.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState());

  final List<BottomNavigationBarItem> bottomNavigationBarItem = [
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_basket_rounded),
      label: "Orders",

    ),

    BottomNavigationBarItem(icon: Icon(Icons.store_rounded), label: "Products"),

    BottomNavigationBarItem(
      icon: Icon(Icons.person_2_rounded),
      label: "Profile",
    ),

    BottomNavigationBarItem(
      icon: Icon(Icons.group_add_rounded),
      label: "Users",
    ),
  ];

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

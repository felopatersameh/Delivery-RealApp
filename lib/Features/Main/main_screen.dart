import 'package:delivery/Features/Products/cubit/products_cubit.dart';
import 'package:delivery/Features/Profile/cubit/profile_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badges;
import '../../Core/Enum/user_type.dart';
import '../Products/products.page.dart';
import 'cubit/main_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => MainCubit())],
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          final cubit = context.read<MainCubit>();
          final type = context.read<ProfileCubit>().state.me;
          return Scaffold(
            backgroundColor: Colors.grey.shade300,
            appBar: AppBar(
              title: Text(
                cubit.nameScreens[state.index],
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 2,
              toolbarHeight: 80.h,
            ),
            body: cubit.screens[state.index],
            bottomNavigationBar: BottomNavigationBar(
              items: cubit.bottomNavigationBarItem(context),
              currentIndex: state.index,
              onTap: (value) => cubit.changeIndex(value),
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
            ),
            floatingActionButton:
                ((type?.userType == UserType.admin) && state.index == 1)
                ? FloatingActionButton(
                    onPressed: () async => await _showAddProductBottomSheet(
                      context,
                      type?.id ?? "0p0",
                    ),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
    );
  }
}

Widget bottomNavIconWithBadge(int newUsersCount, IconData iconData) {
  return badges.Badge(
    position: badges.BadgePosition.topEnd(top: -4, end: -4),
    badgeContent: Text(
      '$newUsersCount',
      style: TextStyle(color: Colors.white, fontSize: 12.sp),
    ),
    showBadge: newUsersCount > 0,
    child: Icon(iconData, size: 30.sp),
  );
}

Future<void> _showAddProductBottomSheet(BuildContext context, String id) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddProductBottomSheet(
      onProductAdded: (newProduct) {
        context.read<ProductsCubit>().addProduct(newProduct);
      },
      currentUserId: id,
    ),
  );
}

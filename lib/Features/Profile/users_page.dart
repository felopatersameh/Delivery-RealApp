import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Features/Profile/Model/user_modell.dart';
import 'package:delivery/Features/Profile/Widgets/alphabetical_user_list.dart';
import 'package:delivery/Features/Profile/Widgets/search_results_list.dart';
import 'package:delivery/Features/Profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Group users by first letter for alphabetical sections
Map<String, List<UserModell>> _groupUsersByLetter(
  List<UserModell> userList,
  bool clientOnly,
  String id,
) {
  Map<String, List<UserModell>> grouped = {};
  for (UserModell user in userList) {
    if (id != user.id) {
      if (clientOnly && (user.typeText == UserType.client.displayName)) {
        String letter = user.firstLetter;
        if (!grouped.containsKey(letter)) {
          grouped[letter] = [];
        }
        grouped[letter]!.add(user);
      }
      if (!clientOnly) {
        String letter = user.firstLetter;
        if (!grouped.containsKey(letter)) {
          grouped[letter] = [];
        }
        grouped[letter]!.add(user);
      }
    }
   
  }
  // Sort the keys alphabetically
  var sortedKeys = grouped.keys.toList()..sort();
  Map<String, List<UserModell>> sortedGrouped = {};
  for (String key in sortedKeys) {
    sortedGrouped[key] = grouped[key]!;
  }
  return sortedGrouped;
}

class UsersPage extends StatefulWidget {
  final UserType currentUserType;

  const UsersPage({super.key, this.currentUserType = UserType.client});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize ProfileCubit when page loads
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<ProfileCubit>().init();
    // });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<UserModell> _getFilteredUsers(List<UserModell> allUsers, String query) {
    if (query.isEmpty) {
      final sorted = List<UserModell>.from(allUsers);
      sorted.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return sorted;
    }

    final filtered = allUsers.where((user) {
      final queryLower = query.toLowerCase();
      bool matchesName = user.name.toLowerCase().contains(queryLower);
      bool matchesEmail = user.email.toLowerCase().contains(queryLower);
      bool matchesPhone = user.phone.toLowerCase().contains(queryLower);
      bool matchesType = user.typeText.toLowerCase().contains(queryLower);

      return matchesName || matchesEmail || matchesPhone || matchesType;
    }).toList();

    filtered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Search Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  color: Colors.white,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      // Trigger rebuild by calling setState minimally or using StreamBuilder
                      // But since we removed setState, we'll use a different approach
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone, or type...',
                      hintStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),

                // Content with ValueListenableBuilder for search reactivity
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (context, searchValue, child) {
                      final allUsers = state.allUsers ?? [];
                      final filteredUsers = _getFilteredUsers(
                        allUsers,
                        searchValue.text,
                      );
                      final isSearching = searchValue.text.isNotEmpty;

                      return Column(
                        children: [
                          // Users Count (only for non-client users)
                          if (widget.currentUserType != UserType.client)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              color: Colors.blue.shade50,
                              child: Text(
                                '${filteredUsers.length} user${filteredUsers.length != 1 ? 's' : ''} found',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          // Users List
                          Expanded(
                            child: filteredUsers.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64.sp,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          allUsers.isEmpty
                                              ? 'Loading users...'
                                              : isSearching
                                              ? 'No users found'
                                              : 'No users available',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : isSearching
                                ? SearchResultsList(
                                    filteredUsers: filteredUsers,
                                    currentUserType: state.me!.userType,
                                    idUser: state.me?.id ?? "",
                                    onUserTap: (data) {},
                                  )
                                : AlphabeticalUserList(
                                    filteredUsers: filteredUsers,
                                    currentUserType: state.me!.userType,
                                    groupUsersByLetter: (users, p0) =>
                                        _groupUsersByLetter(
                                          users,
                                          p0,
                                          state.me!.id,
                                        ),
                                    onUserTap: (data) {},
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

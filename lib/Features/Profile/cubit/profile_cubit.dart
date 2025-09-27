import 'package:bloc/bloc.dart';
import 'package:delivery/Features/Profile/Model/user_modell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Core/Database/real_time_firbase.dart';
import '../../../Core/Local/local_storage.dart';
import '../../../Core/Local/local_storage_keys.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState());
  String? _userListenerId;
  Future<void> init() async {
    try {
      final idUser = await LocalStorageService.getValue(
        LocalStorageKeys.idUser,
      );

      // Step 1: Get initial data
      final allUsersSnapshot = await RealtimeFirebase.getData('users');
      final allUsersRaw = Map<String, dynamic>.from(allUsersSnapshot ?? {});

      // Step 2: Parse to List<UserModell>
      final List<UserModell> allUsers = allUsersRaw.entries.map((entry) {
        final key = entry.key;
        final map = Map<String, dynamic>.from(entry.value);
        return UserModell.fromMap(key, map);
      }).toList();

      // Step 3: Find current user
      final me = allUsers.firstWhere(
        (user) => user.id == idUser,
        orElse: () => throw Exception('User not found'),
      );

      // Step 4: Emit initial state
      emit(state.copyWith(allUsers: allUsers, me: me));

      // Step 5: Start listening for real-time updates
      _userListenerId = listenToUsers(
        onChange: (data) {
          final updatedUsers = data.entries.map((entry) {
            final key = entry.key;
            final map = Map<String, dynamic>.from(entry.value);
            return UserModell.fromMap(key, map);
          }).toList();

          final updatedMe = updatedUsers.firstWhere(
            (user) => user.id == idUser,
            // orElse: () => null,
          );

          emit(state.copyWith(allUsers: updatedUsers, me: updatedMe));
        },
        onError: (error) {
          debugPrint('Listen to users failed: $error');
        },
      );
    } catch (e) {
      debugPrint('Error in init(): $e');
    }
  }

  String listenToUsers({
    required void Function(Map<String, dynamic> allUsers) onChange,
    Function(Object error)? onError,
  }) {
    final listenerId = RealtimeFirebase.listen('users', (data, key) {
      if (data != null && data is Map) {
        final allUsers = Map<String, dynamic>.from(data);
        onChange(allUsers);
      }
    }, onError: onError);

    return listenerId;
  }

  Future<void> stopListeningToUsers() async {
    if (_userListenerId != null) {
      await RealtimeFirebase.unlisten(_userListenerId!);
      _userListenerId = null;
    }
  }

  @override
  Future<void> close() {
    stopListeningToUsers();
    return super.close();
  }
}

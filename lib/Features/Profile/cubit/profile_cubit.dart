import 'package:bloc/bloc.dart';
import 'package:delivery/Core/Notifications/notification_services.dart';
import 'package:delivery/Features/Profile/Model/user_modell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Core/Database/real_time_firbase.dart';
import '../../../Core/Local/local_storage.dart';
import '../../../Core/Local/local_storage_keys.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  NotificationServices notificationServices = NotificationServices();
  ProfileCubit() : super(ProfileState());
  String? _userListenerId;
  Future<void> init() async {
    try {
      final idUser = await LocalStorageService.getValue(
        LocalStorageKeys.idUser,
      );

      final allUsersSnapshot = await RealtimeFirebase.getData('users');
      final allUsersRaw = Map<String, dynamic>.from(allUsersSnapshot ?? {});

      final List<UserModell> allUsers = allUsersRaw.entries.map((entry) {
        final key = entry.key;
        final map = Map<String, dynamic>.from(entry.value);
        return UserModell.fromMap(key, map);
      }).toList();

      final me = allUsers.firstWhere(
        (user) => user.id == idUser,
        orElse: () => throw Exception('User not found'),
      );

      emit(state.copyWith(allUsers: allUsers, me: me));
      //------------------------------------------------------------------------- Part 2 [listenToUsers]
      // Start listening for real-time updates
      _userListenerId = listenToUsers(
        onChange: (data) {
          final oldUsers = state.allUsers ?? [];

          final oldIds = oldUsers.map((u) => u.id).toSet();
          final updatedRaw = Map<String, dynamic>.from(data);
          final updatedIds = updatedRaw.keys.toSet();

          // فقط IDs الجداد
          final newIds = updatedIds.difference(oldIds).toList();

          final updatedUsers = updatedRaw.entries.map((entry) {
            final key = entry.key;
            final map = Map<String, dynamic>.from(entry.value);
            return UserModell.fromMap(key, map);
          }).toList();

          final updatedMe = updatedUsers.firstWhere(
            (user) => user.id == idUser,
            orElse: () => state.me!,
          );
          emit(
            state.copyWith(
              allUsers: updatedUsers,
              me: updatedMe,
              badge: newIds.length,
              newUserIds: newIds,
            ),
          );
        },
        onError: (error) {
          debugPrint('Listen to users failed: $error');
        },
      );
    } catch (e) {
      debugPrint('Error in init(): $e');
    }
  }

  void resetBadge() => emit(state.copyWith(badge: 0, newUserIds: []));

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

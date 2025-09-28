
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Core/Database/real_time_firbase.dart';
import '../../../Core/Enum/user_type.dart';
import '../../../Core/Local/local_storage.dart';
import '../../../Core/Local/local_storage_keys.dart';
import '../../../Core/Notifications/notification_services.dart';
import '../Model/user_modell.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  NotificationServices notificationServices = NotificationServices();
  ProfileCubit() : super(ProfileState());
  String? _userListenerId;

  Future<void> init() async {
    try {
      await _loadInitialUsers();
      _listenToUsersChanges();
    } catch (e) {
      debugPrint('Error in init(): $e');
    }
  }

  Future<void> _loadInitialUsers() async {
    final idUser = await LocalStorageService.getValue(LocalStorageKeys.idUser);
    final List<String> oldIds = List<String>.from(
      await LocalStorageService.getValue(
        LocalStorageKeys.idUsers,
        defaultValue: [],
      ),
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

    final bool isMeClient = me.userType == UserType.client;

    final List<String> newIds = allUsers
        .where((user) {
          if (isMeClient) {
            return user.userType == UserType.client && user.id != me.id;
          } else {
            return true;
          }
        })
        .map((user) => user.id)
        .toList();

    final List<String> addedIds = newIds
        .where((id) => !oldIds.contains(id))
        .toList();
    await LocalStorageService.setValue(LocalStorageKeys.idUsers, newIds);

    emit(
      state.copyWith(
        allUsers: allUsers,
        me: me,
        badge: addedIds.length,
        newUserIds: addedIds,
      ),
    );
  }

  void _listenToUsersChanges() async {
    final idUser = await LocalStorageService.getValue(LocalStorageKeys.idUser);

    _userListenerId = _listenToUsers(
      onChange: (data) {
        final oldUsers = state.allUsers ?? [];
        final oldIds = oldUsers.map((u) => u.id).toSet();

        final updatedRaw = Map<String, dynamic>.from(data);
        final updatedIds = updatedRaw.keys.toSet();

        // Detect only newly added users
        final newIds = updatedIds.difference(oldIds).toList();

        // Return early if nothing changed
        if (newIds.isEmpty && updatedIds.length == oldUsers.length) return;

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
  }

  void resetBadge() => emit(state.copyWith(badge: 0, newUserIds: []));

  String _listenToUsers({
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

  Future<void> _stopListeningToUsers() async {
    if (_userListenerId != null) {
      await RealtimeFirebase.unlisten(_userListenerId!);
      _userListenerId = null;
    }
  }

  @override
  Future<void> close() {
    _stopListeningToUsers();
    return super.close();
  }

}

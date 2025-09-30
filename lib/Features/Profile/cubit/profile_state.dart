part of 'profile_cubit.dart';

class ProfileState {
  final List<UserModell>? allUsers;
  final UserModell? me;
  final int badge;
  final List<String>? newUserIds;
  ProfileState({
    this.allUsers = const [],
    this.me,
    this.badge = 0,
    this.newUserIds = const [],
  });

  ProfileState copyWith({
    List<UserModell>? allUsers,
    UserModell? me,
    int? badge,
    List<String>? newUserIds,
  }) {
    return ProfileState(
      allUsers: allUsers ?? this.allUsers,
      me: me ?? this.me,
      badge: badge ?? this.badge,
      newUserIds: newUserIds ?? this.newUserIds,
    );
  }
}

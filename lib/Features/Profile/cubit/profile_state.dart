part of 'profile_cubit.dart';

class ProfileState {
  final List<UserModell>? allUsers;
  final UserModell? me;
  ProfileState({this.allUsers = const [], this.me});

  ProfileState copyWith({List<UserModell>? allUsers, UserModell? me}) {
    return ProfileState(allUsers: allUsers ?? this.allUsers, me: me ?? this.me);
  }
}

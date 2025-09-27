part of 'main_cubit.dart';

@immutable
class MainState {
  final int index;
  const MainState({this.index = 0});
  MainState copyWith({int? index}) {
    return MainState(index: index ?? this.index);
  }
}

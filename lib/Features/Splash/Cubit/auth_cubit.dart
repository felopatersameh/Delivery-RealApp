import '../../../Core/Enum/user_type.dart';
import '../../../Core/Local/local_storage.dart';
import '../../../Core/Local/local_storage_keys.dart';
import 'auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Core/Database/real_time_firbase.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
  }) async {
    emit(AuthLoading());

    try {
      final snapshot = await RealtimeFirebase.query(
        'users',
        orderByChild: 'email',
        equalTo: email,
      );

      if (snapshot != null && (snapshot as Map).isNotEmpty) {
        emit(AuthError('Email already exists'));
        return;
      }
      final tokenFCM = await LocalStorageService.getValue(
        LocalStorageKeys.tokenFCM,
      );
      final respose = await RealtimeFirebase.create('users', {
        'tokenFCM': tokenFCM,
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'type': userType.name,
      });
      LocalStorageService.setValue(LocalStorageKeys.idUser, respose);

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError('Signup failed: ${e.toString()}'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      final tokenFCM = await LocalStorageService.getValue(
        LocalStorageKeys.tokenFCM,
      );

      final snapshot = await RealtimeFirebase.query(
        'users',
        orderByChild: 'email',
        equalTo: email,
      );

      if (snapshot != null) {
        final userMap = Map<String, dynamic>.from(snapshot as Map);
        final id = userMap.keys.first;
        final user = userMap[id] as Map;

        if (user['password'] == password) {
          await RealtimeFirebase.updateData('users/$id', {
            'tokenFCM': tokenFCM,
          });
          LocalStorageService.setValue(LocalStorageKeys.idUser, id);

          emit(AuthSuccess());
          return;
        }
      }

      emit(AuthError('Invalid email or password'));
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }
}

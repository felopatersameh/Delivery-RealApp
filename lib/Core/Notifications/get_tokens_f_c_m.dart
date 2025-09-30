import '../Database/real_time_firbase.dart';
import '../Local/local_storage.dart';
import '../Local/local_storage_keys.dart';

class GetTokensFCM {
  static Future<List<String>> getAllUserFcmTokens() async {
    final data = await RealtimeFirebase.getData('users');
    final raw = Map<String, dynamic>.from(data ?? {});
    final String id = await LocalStorageService.getValue(
      LocalStorageKeys.idUser,
    );

    final List<String> allTokens = [];

    for (var userEntry in raw.entries) {
      final String userId = userEntry.key;

      if (userId == id) continue; // ⛔ تجاهل المستخدم الحالي

      final userMap = Map<String, dynamic>.from(userEntry.value);
      final token = userMap['tokenFCM'];

      if (token != null && token.toString().isNotEmpty) {
        allTokens.add(token.toString());
      }
    }

    return allTokens;
  }

  static Future<List<String>> getTokensByUserType(String userType) async {
    final data = await RealtimeFirebase.getData('users');
    final raw = Map<String, dynamic>.from(data ?? {});
    final List<String> tokens = [];

    for (var userEntry in raw.entries) {
      final userMap = Map<String, dynamic>.from(userEntry.value);
      if (userMap['type'] == userType) {
        final String token = userMap['tokenFCM'];
        if (token.isNotEmpty) {
          tokens.add(token.toString());
        }
      } else {}
    }

    return tokens;
  }

  static Future<List<String>> getTokensByUserIds(List<String> userIds) async {
    final data = await RealtimeFirebase.getData('users');
    final raw = Map<String, dynamic>.from(data ?? {});
    final List<String> tokens = [];

    for (var id in userIds) {
      final userMap = raw[id];
      if (userMap != null && userMap is Map) {
        final map = Map<String, dynamic>.from(userMap);
        final token = map['tokenFCM'];
        if (token != null && token.toString().isNotEmpty) {
          tokens.add(token.toString());
        }
      }
    }

    return tokens;
  }
}

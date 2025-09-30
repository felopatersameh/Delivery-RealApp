import 'dart:developer';
import 'package:hive/hive.dart';

import 'local_storage_keys.dart';

class LocalStorageService {
  static Box? _box;

  static bool enableLogging = false;

  static bool get isInitialized => _box != null && _box!.isOpen;

  static Future<void> init({
    required String boxName,
    bool enableLogging = false,
  }) async {
    if (boxName.trim().isEmpty) {
      throw ArgumentError('Box name cannot be empty');
    }

    try {
      LocalStorageService.enableLogging = enableLogging;
      _box = await Hive.openBox(boxName.trim());

      await _viewMessage(
        message: "Storage initialized successfully with box: ${boxName.trim()}",
        key: "INIT",
        type: "init",
      );
    } catch (e) {
      await _viewMessage(
        message: "Failed to initialize storage: $e",
        key: "INIT_ERROR",
        type: "error",
      );
      rethrow;
    }
  }

  static Future<void> setValue(String key, dynamic value) async {
    _ensureInitialized();

    if (key.trim().isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }

    try {
      await _box!.put(key.trim(), value);
      await _viewMessage(
        message: value.toString(),
        key: key.trim(),
        type: 'setValue',
      );
    } catch (e) {
      await _viewMessage(
        message: "Error setting value: $e",
        key: key.trim(),
        type: 'error',
      );
      rethrow;
    }
  }

  static Future<dynamic> getValue(String key, {dynamic defaultValue}) async {
    _ensureInitialized();

    if (key.trim().isEmpty) {
      await _viewMessage(
        message: "Empty key provided, returning default value",
        key: "EMPTY_KEY",
        type: 'error',
      );
      return defaultValue;
    }

    try {
      final value = _box!.get(key.trim(), defaultValue: defaultValue);
      await _viewMessage(
        message: value.toString(),
        key: key.trim(),
        type: 'getValue',
      );
      return value;
    } catch (e) {
      await _viewMessage(
        message: "Error getting value: $e",
        key: key.trim(),
        type: 'error',
      );
      return defaultValue;
    }
  }

  static dynamic getValueSync(String key, {dynamic defaultValue}) {
    _ensureInitializedSync();

    if (key.trim().isEmpty) {
      _viewMessageSync(
        message: "Empty key provided, returning default value",
        key: "EMPTY_KEY",
        type: 'error',
      );
      return defaultValue;
    }

    try {
      final value = _box!.get(key.trim(), defaultValue: defaultValue);
      _viewMessageSync(
        message: value.toString(),
        key: key.trim(),
        type: 'getValueSync',
      );
      return value;
    } catch (e) {
      _viewMessageSync(
        message: "Error getting value: $e",
        key: key.trim(),
        type: 'error',
      );
      return defaultValue;
    }
  }

  static Future<void> removeValue(String key) async {
    _ensureInitialized();

    if (key.trim().isEmpty) {
      throw ArgumentError('Key cannot be empty');
    }

    try {
      await _box!.delete(key.trim());
      await _viewMessage(
        message: "Deleted",
        key: key.trim(),
        type: 'removeValue',
      );
    } catch (e) {
      await _viewMessage(
        message: "Error deleting value: $e",
        key: key.trim(),
        type: 'error',
      );
      rethrow;
    }
  }

  static Future<void> clear() async {
    _ensureInitialized();

    try {
      await _box!.clear();
      await _viewMessage(
        message: "All data cleared",
        key: "CLEAR",
        type: 'clear',
      );
    } catch (e) {
      await _viewMessage(
        message: "Error clearing data: $e",
        key: "CLEAR_ERROR",
        type: 'error',
      );
      rethrow;
    }
  }

  static bool containsKey(String key) {
    _ensureInitializedSync();

    if (key.trim().isEmpty) {
      _viewMessageSync(
        message: "Empty key provided",
        key: "EMPTY_KEY",
        type: 'error',
      );
      return false;
    }

    try {
      final exists = _box!.containsKey(key.trim());
      _viewMessageSync(
        message: exists.toString(),
        key: key.trim(),
        type: 'containsKey',
      );
      return exists;
    } catch (e) {
      _viewMessageSync(
        message: "Error checking key: $e",
        key: key.trim(),
        type: 'error',
      );
      return false;
    }
  }

  static List<String> getAllKeys() {
    _ensureInitializedSync();

    try {
      final keys = _box!.keys.cast<String>().toList();
      _viewMessageSync(
        message: "Found ${keys.length} keys",
        key: "ALL_KEYS",
        type: "getAllKeys",
      );
      return keys;
    } catch (e) {
      _viewMessageSync(
        message: "Error getting keys: $e",
        key: "ALL_KEYS_ERROR",
        type: "error",
      );
      return [];
    }
  }

  static int getStorageSize() {
    _ensureInitializedSync();

    try {
      final size = _box!.length;
      _viewMessageSync(
        message: "$size items",
        key: "STORAGE_SIZE",
        type: "getStorageSize",
      );
      return size;
    } catch (e) {
      _viewMessageSync(
        message: "Error getting size: $e",
        key: "STORAGE_SIZE_ERROR",
        type: "error",
      );
      return 0;
    }
  }

  static Future<void> close() async {
    if (_box?.isOpen == true) {
      try {
        await _box!.close();
        await _viewMessage(
          message: "Storage closed",
          key: "CLOSE",
          type: "close",
        );
      } catch (e) {
        await _viewMessage(
          message: "Error closing storage: $e",
          key: "CLOSE_ERROR",
          type: "error",
        );
      }
    }
  }

  static bool get isOpen => _box?.isOpen ?? false;

  static Future<void> saveToken(String token) async {
    if (token.trim().isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }
    await setValue(LocalStorageKeys.token, token.trim());
  }

  static Future<String?> getToken() async {
    final token = await getValue(LocalStorageKeys.token) as String?;
    return token?.trim().isEmpty == true ? null : token?.trim();
  }

  static Future<void> removeToken() async {
    await removeValue(LocalStorageKeys.token);
  }

  static void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError(
        'LocalStorageService not initialized. Call init() first.',
      );
    }
  }

  static void _ensureInitializedSync() {
    if (!isInitialized) {
      throw StateError(
        'LocalStorageService not initialized. Call init() first.',
      );
    }
  }

  static Future<void> _viewMessage({
    required String message,
    required String key,
    required String type,
  }) async {
    if (enableLogging &&
        message.isNotEmpty &&
        key.isNotEmpty &&
        type.isNotEmpty) {
      log("[$type] [$key] ::: $message");
    }
  }

  static void _viewMessageSync({
    required String message,
    required String key,
    required String type,
  }) {
    if (enableLogging &&
        message.isNotEmpty &&
        key.isNotEmpty &&
        type.isNotEmpty) {
      log("[$type] [$key] ::: $message");
    }
  }
}

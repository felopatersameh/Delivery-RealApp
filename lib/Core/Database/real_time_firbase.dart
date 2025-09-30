import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:developer' as developer;

class RealtimeFirebase {
  static FirebaseDatabase? _database;
  static final Map<String, StreamSubscription> _listeners = {};
  static bool _initialized = false;

  /// Initialize Firebase Realtime Database
  /// Call this after Firebase.initializeApp() in main()
  static Future<void> initialize({String? databaseURL}) async {
    try {
      if (!_initialized) {
        _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: databaseURL,
        );
        _database!.setPersistenceEnabled(true);
        _initialized = true;
        developer.log('RealtimeFirebase initialized successfully');
      }
    } catch (e) {
      developer.log('RealtimeFirebase initialization failed: $e');
      throw Exception('Firebase initialization failed: $e');
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized && _database != null;

  /// Create a new record with auto-generated key
  /// Returns the generated key
  static Future<String> create(String path, Map<String, dynamic> data) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      final newRef = ref.push();
      
      final dataWithTimestamps = {
        ...data,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'id':newRef.key
      };
      
      await newRef.set(dataWithTimestamps);
      return newRef.key!;
    } catch (e) {
      developer.log('Create operation failed: $e');
      throw Exception('Create operation failed: $e');
    }
  }

  /// Set data at specific path
  static Future<void> setData(String path, Map<String, dynamic> data) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      final dataWithTimestamp = {
        ...data,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      await ref.set(dataWithTimestamp);
    } catch (e) {
      developer.log('Set operation failed: $e');
      throw Exception('Set operation failed: $e');
    }
  }

  /// Get data from specific path
  /// Returns null if data doesn't exist
  static Future<dynamic> getData(String path) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      final snapshot = await ref.get();
      return snapshot.exists ? snapshot.value : null;
    } catch (e) {
      developer.log('Get operation failed: $e');
      throw Exception('Get operation failed: $e');
    }
  }

  /// Update specific fields at path
  static Future<void> updateData(String path, Map<String, dynamic> updates) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      final updatesWithTimestamp = {
        ...updates,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      await ref.update(updatesWithTimestamp);
    } catch (e) {
      developer.log('Update operation failed: $e');
      throw Exception('Update operation failed: $e');
    }
  }

  /// Delete data at specific path
  static Future<void> deleteData(String path) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      await ref.remove();
    } catch (e) {
      developer.log('Delete operation failed: $e');
      throw Exception('Delete operation failed: $e');
    }
  }

  /// Listen to real-time changes at path
  /// Returns listener ID for managing the subscription
  static String listen(
    String path,
    Function(dynamic data, String? key) onData, {
    Function(Object error)? onError,
    String? listenerId,
  }) {
    _checkInitialization();
    
    final id = listenerId ?? '${path}_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      final ref = _database!.ref(path);
      final subscription = ref.onValue.listen(
        (event) {
          final data = event.snapshot.exists ? event.snapshot.value : null;
          onData(data, event.snapshot.key);
        },
        onError: (error) {
          developer.log('Listen operation failed: $error');
          if (onError != null) {
            onError(error);
          }
        },
      );
      
      _listeners[id] = subscription;
      return id;
    } catch (e) {
      developer.log('Listen setup failed: $e');
      throw Exception('Listen setup failed: $e');
    }
  }

  /// Stop listening to specific path
  static Future<void> unlisten(String listenerId) async {
    if (_listeners.containsKey(listenerId)) {
      await _listeners[listenerId]!.cancel();
      _listeners.remove(listenerId);
    }
  }

  /// Stop all listeners
  static Future<void> unlistenAll() async {
    for (final subscription in _listeners.values) {
      await subscription.cancel();
    }
    _listeners.clear();
  }

  /// Query data with conditions
  static Future<dynamic> query(
    String path, {
    String? orderByChild,
    bool orderByKey = false,
    bool orderByValue = false,
    dynamic startAt,
    dynamic endAt,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
  }) async {
    _checkInitialization();
    try {
      DatabaseReference ref = _database!.ref(path);
      Query query = ref;

      // Apply ordering
      if (orderByChild != null) {
        query = query.orderByChild(orderByChild);
      } else if (orderByKey) {
        query = query.orderByKey();
      } else if (orderByValue) {
        query = query.orderByValue();
      }

      // Apply filters
      if (equalTo != null) {
        query = query.equalTo(equalTo);
      }
      if (startAt != null) {
        query = query.startAt(startAt);
      }
      if (endAt != null) {
        query = query.endAt(endAt);
      }

      // Apply limits
      if (limitToFirst != null) {
        query = query.limitToFirst(limitToFirst);
      }
      if (limitToLast != null) {
        query = query.limitToLast(limitToLast);
      }

      final snapshot = await query.get();
      return snapshot.exists ? snapshot.value : null;
    } catch (e) {
      developer.log('Query operation failed: $e');
      throw Exception('Query operation failed: $e');
    }
  }

  /// Listen to query results in real-time
  static String queryListen(
    String path,
    Function(dynamic data, String? key) onData, {
    String? orderByChild,
    bool orderByKey = false,
    bool orderByValue = false,
    dynamic startAt,
    dynamic endAt,
    dynamic equalTo,
    int? limitToFirst,
    int? limitToLast,
    Function(Object error)? onError,
    String? listenerId,
  }) {
    _checkInitialization();
    
    final id = listenerId ?? 'query_${path}_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      DatabaseReference ref = _database!.ref(path);
      Query query = ref;

      // Apply same query logic as query method
      if (orderByChild != null) {
        query = query.orderByChild(orderByChild);
      } else if (orderByKey) {
        query = query.orderByKey();
      } else if (orderByValue) {
        query = query.orderByValue();
      }

      if (equalTo != null) {
        query = query.equalTo(equalTo);
      }
      if (startAt != null) {
        query = query.startAt(startAt);
      }
      if (endAt != null) {
        query = query.endAt(endAt);
      }
      if (limitToFirst != null) {
        query = query.limitToFirst(limitToFirst);
      }
      if (limitToLast != null) {
        query = query.limitToLast(limitToLast);
      }

      final subscription = query.onValue.listen(
        (event) {
          final data = event.snapshot.exists ? event.snapshot.value : null;
          onData(data, event.snapshot.key);
        },
        onError: (error) {
          developer.log('Query listen operation failed: $error');
          if (onError != null) {
            onError(error);
          }
        },
      );
      
      _listeners[id] = subscription;
      return id;
    } catch (e) {
      developer.log('Query listen setup failed: $e');
      throw Exception('Query listen setup failed: $e');
    }
  }

  /// Batch update multiple paths atomically
  static Future<void> batchUpdate(Map<String, dynamic> updates) async {
    _checkInitialization();
    try {
      final ref = _database!.ref();
      final timestampedUpdates = <String, dynamic>{};
      
      updates.forEach((path, value) {
        if (value is Map<String, dynamic>) {
          timestampedUpdates[path] = {
            ...value,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          };
        } else {
          timestampedUpdates[path] = value;
        }
      });

      await ref.update(timestampedUpdates);
    } catch (e) {
      developer.log('Batch update failed: $e');
      throw Exception('Batch update failed: $e');
    }
  }

  /// Check if a path exists
  static Future<bool> exists(String path) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      final snapshot = await ref.get();
      return snapshot.exists;
    } catch (e) {
      developer.log('Exists check failed: $e');
      throw Exception('Exists check failed: $e');
    }
  }

  /// Get Firebase server timestamp placeholder
  static Map<String, String> get serverTimestamp => {'.sv': 'timestamp'};

  /// Listen to connection state changes
  static String onConnectionState(Function(bool isConnected) callback, {String? listenerId}) {
    _checkInitialization();
    
    final id = listenerId ?? 'connection_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      final ref = _database!.ref('.info/connected');
      final subscription = ref.onValue.listen(
        (event) {
          final isConnected = event.snapshot.value == true;
          callback(isConnected);
        },
        onError: (error) {
          developer.log('Connection state listener error: $error');
          callback(false);
        },
      );
      
      _listeners[id] = subscription;
      return id;
    } catch (e) {
      developer.log('Connection state listener setup failed: $e');
      throw Exception('Connection state listener setup failed: $e');
    }
  }

  /// Get count of active listeners
  static int get activeListenersCount => _listeners.length;

  /// Get list of active listener IDs
  static List<String> get activeListenerIds => _listeners.keys.toList();

  /// Enable offline persistence (call before any database operations)
  static void enablePersistence() {
    if (_database != null) {
      _database!.setPersistenceEnabled(true);
    }
  }

  /// Disable offline persistence
  static void disablePersistence() {
    if (_database != null) {
      _database!.setPersistenceEnabled(false);
    }
  }

  /// Get database reference for advanced operations
  static DatabaseReference ref(String path) {
    _checkInitialization();
    return _database!.ref(path);
  }

  /// Private method to check initialization
  static void _checkInitialization() {
    if (!isInitialized) {
      throw Exception('RealtimeFirebase not initialized. Call RealtimeFirebase.initialize() first.');
    }
  }

  /// Clean up all resources (call when app is disposed)
  static Future<void> dispose() async {
    await unlistenAll();
    _initialized = false;
    _database = null;
  }

  /// Transaction operation for atomic updates
  static Future<T?> runTransaction<T>(
    String path,
    T? Function(T? currentValue) updateFunction,
  ) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      final result = await ref.runTransaction((currentData) {
        return Transaction.success(updateFunction(currentData as T?));
      });
      return result.snapshot.value as T?;
    } catch (e) {
      developer.log('Transaction failed: $e');
      throw Exception('Transaction failed: $e');
    }
  }

  /// Push multiple items at once
  static Future<List<String>> pushMultiple(
    String path, 
    List<Map<String, dynamic>> items,
  ) async {
    _checkInitialization();
    try {
      final ref = _database!.ref(path);
      final keys = <String>[];
      
      for (final item in items) {
        final newRef = ref.push();
        final dataWithTimestamps = {
          ...item,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        };
        await newRef.set(dataWithTimestamps);
        keys.add(newRef.key!);
      }
      
      return keys;
    } catch (e) {
      developer.log('Push multiple failed: $e');
      throw Exception('Push multiple failed: $e');
    }
  }
}
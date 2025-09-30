// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as ioo;

// class SocketClient {
//   static final SocketClient _instance = SocketClient._internal();
//   factory SocketClient() => _instance;
//   SocketClient._internal();

//   ioo.Socket? _socket;
//   String? _serverUrl;
//   bool _isConnected = false;
//   Timer? _reconnectTimer;
//   int _reconnectAttempts = 0;
//   final int _maxReconnectAttempts = 5;
//   final Duration _reconnectDelay = const Duration(seconds: 3);

//   // Stream controllers for connection status
//   final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
//   final StreamController<String> _messageController = StreamController<String>.broadcast();
//   final StreamController<Map<String, dynamic>> _errorController = StreamController<Map<String, dynamic>>.broadcast();

//   // Getters
//   bool get isConnected => _isConnected;
//   ioo.Socket? get socket => _socket;
//   Stream<bool> get connectionStream => _connectionController.stream;
//   Stream<String> get messageStream => _messageController.stream;
//   Stream<Map<String, dynamic>> get errorStream => _errorController.stream;

//   /// Initialize and connect to socket server
//   Future<void> connect({
//     required String serverUrl,
//     Map<String, dynamic>? query,
//     Map<String, String>? headers,
//     Duration timeout = const Duration(seconds: 10),
//     bool autoConnect = true,
//     String? namespace,
//   }) async {
//     try {
//       _serverUrl = serverUrl;

//       // Disconnect existing connection if any
//       if (_socket != null) {
//         await disconnect();
//       }

//       // Configure socket options
//       final options = ioo.OptionBuilder()
//           .setTransports(['websocket'])
//           .disableAutoConnect()
//           .setTimeout(timeout.inMilliseconds)
//           .setExtraHeaders(headers ?? {})
//           .setQuery(query ?? {})
//           .build();

//       // Create socket instance
//       _socket = ioo.io(_serverUrl! + (namespace ?? ''), options);

//       // Set up event listeners
//       _setupEventListeners();

//       // Connect if autoConnect is true
//       if (autoConnect) {
//         _socket!.connect();
//         log('Attempting to connect to: $_serverUrl');
//       }

//     } catch (e) {
//       log('Socket connection error: $e');
//       _handleError('CONNECTION_ERROR', e.toString());
//     }
//   }

//   /// Set up socket event listeners
//   void _setupEventListeners() {
//     if (_socket == null) return;

//     // Connection successful
//     _socket!.onConnect((_) {
//       log('Socket connected successfully');
//       _isConnected = true;
//       _reconnectAttempts = 0;
//       _connectionController.add(true);
//       _cancelReconnectTimer();
//     });

//     // Connection error
//     _socket!.onConnectError((error) {
//       log('Socket connection error: $error');
//       _isConnected = false;
//       _connectionController.add(false);
//       _handleError('CONNECT_ERROR', error.toString());
//       _attemptReconnect();
//     });

//     // Disconnection
//     _socket!.onDisconnect((reason) {
//       log('Socket disconnected: $reason');
//       _isConnected = false;
//       _connectionController.add(false);

//       // Auto-reconnect on unexpected disconnection
//       if (reason != 'io client disconnect') {
//         _attemptReconnect();
//       }
//     });

//     // General error handling
//     _socket!.onError((error) {
//       log('Socket error: $error');
//       _handleError('SOCKET_ERROR', error.toString());
//     });

//     // Reconnection attempt
//     _socket!.onReconnectAttempt((attemptNumber) {
//       log('Reconnection attempt: $attemptNumber');
//     });

//     // Reconnection successful
//     _socket!.onReconnect((attemptNumber) {
//       log('Reconnected after $attemptNumber attempts');
//       _isConnected = true;
//       _reconnectAttempts = 0;
//       _connectionController.add(true);
//     });
//   }

//   /// Emit an event to the server
//   void emit(String event, [dynamic data]) {
//     if (_socket != null && _isConnected) {
//       _socket!.emit(event, data);
//       log('Emitted event: $event with data: $data');
//     } else {
//       log('Cannot emit event: Socket not connected');
//       _handleError('EMIT_ERROR', 'Socket not connected');
//     }
//   }

//   /// Listen for events from server
//   void on(String event, Function(dynamic) callback) {
//     if (_socket != null) {
//       _socket!.on(event, callback);
//       log('Listening for event: $event');
//     }
//   }

//   /// Remove event listener
//   void off(String event) {
//     if (_socket != null) {
//       _socket!.off(event);
//       log('Removed listener for event: $event');
//     }
//   }

//   /// Send a message and wait for acknowledgment
//   Future<dynamic> emitWithAck(String event, dynamic data, {Duration timeout = const Duration(seconds: 5)}) async {
//     if (_socket == null || !_isConnected) {
//       throw Exception('Socket not connected');
//     }

//     final completer = Completer<dynamic>();

//     _socket!.emitWithAck(event, data, ack: (response) {
//       if (!completer.isCompleted) {
//         completer.complete(response);
//       }
//     });

//     // Set timeout
//     Timer(timeout, () {
//       if (!completer.isCompleted) {
//         completer.completeError(TimeoutException('Emit acknowledgment timeout', timeout));
//       }
//     });

//     return completer.future;
//   }

//   /// Join a room
//   void joinRoom(String roomId, {Map<String, dynamic>? data}) {
//     final payload = {'room': roomId, ...?data};
//     emit('join_room', payload);
//   }

//   /// Leave a room
//   void leaveRoom(String roomId, {Map<String, dynamic>? data}) {
//     final payload = {'room': roomId, ...?data};
//     emit('leave_room', payload);
//   }

//   /// Send message to a specific room
//   void sendToRoom(String roomId, String event, dynamic data) {
//     final payload = {
//       'room': roomId,
//       'event': event,
//       'data': data,
//     };
//     emit('room_message', payload);
//   }

//   /// Attempt to reconnect
//   void _attemptReconnect() {
//     if (_reconnectAttempts >= _maxReconnectAttempts) {
//       log('Max reconnection attempts reached');
//       _handleError('MAX_RECONNECT_ATTEMPTS', 'Maximum reconnection attempts exceeded');
//       return;
//     }

//     _cancelReconnectTimer();

//     _reconnectTimer = Timer(_reconnectDelay, () {
//       _reconnectAttempts++;
//       log('Attempting to reconnect... ($_reconnectAttempts/$_maxReconnectAttempts)');

//       if (_socket != null) {
//         _socket!.connect();
//       }
//     });
//   }

//   /// Cancel reconnection timer
//   void _cancelReconnectTimer() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//   }

//   /// Handle errors
//   void _handleError(String type, String message) {
//     final error = {
//       'type': type,
//       'message': message,
//       'timestamp': DateTime.now().toIso8601String(),
//     };
//     _errorController.add(error);
//   }

//   /// Manually trigger reconnection
//   void reconnect() {
//     if (_socket != null) {
//       log('Manual reconnection triggered');
//       _socket!.disconnect();
//       _socket!.connect();
//     }
//   }

//   /// Check connection status
//   Future<bool> checkConnection() async {
//     if (_socket == null) return false;

//     try {
//       final response = await emitWithAck('ping', null, timeout: const Duration(seconds: 3));
//       return response != null;
//     } catch (e) {
//       log('Connection check failed: $e');
//       return false;
//     }
//   }

//   /// Disconnect from socket server
//   Future<void> disconnect() async {
//     if (_socket != null) {
//       _cancelReconnectTimer();
//       _socket!.disconnect();
//       _socket!.dispose();
//       _socket = null;
//       _isConnected = false;
//       _reconnectAttempts = 0;
//       _connectionController.add(false);
//       log('Socket disconnected');
//     }
//   }

//   void dispose() {
//     disconnect();
//     _connectionController.close();
//     _messageController.close();
//     _errorController.close();
//   }
// }

// // Usage Example Class
// class SocketUsageExample {
//   final SocketClient _socketClient = SocketClient();

//   void initializeSocket() async {
//     // Connect to socket server
//     await _socketClient.connect(
//       serverUrl: 'http://localhost:3000',
//       query: {'userId': 'user123'},
//       headers: {'Authorization': 'Bearer your-token'},
//       autoConnect: true,
//     );

//     // Listen for connection status
//     _socketClient.connectionStream.listen((isConnected) {
//       // debugPrint('Connection status: $isConnected');
//     });

//     // Listen for errors
//     _socketClient.errorStream.listen((error) {
//       debugPrint('Socket error: ${error['type']} - ${error['message']}');
//     });

//     // Listen for custom events
//     _socketClient.on('message', (data) {
//       debugPrint('Received message: $data');
//     });

//     _socketClient.on('notification', (data) {
//       debugPrint('Received notification: $data');
//     });

//     // Send a message
//     _socketClient.emit('send_message', {
//       'message': 'Hello from Flutter!',
//       'timestamp': DateTime.now().toIso8601String(),
//     });

//     // Join a room
//     _socketClient.joinRoom('chat_room_1');

//     // Send message with acknowledgment
//     try {
//       final response = await _socketClient.emitWithAck('important_message', {
//         'content': 'This needs confirmation',
//       });
//       debugPrint('Server acknowledged: $response');
//     } catch (e) {
//       debugPrint('Message not acknowledged: $e');
//     }
//   }

//   void disconnectSocket() {
//     _socketClient.disconnect();
//   }
// }

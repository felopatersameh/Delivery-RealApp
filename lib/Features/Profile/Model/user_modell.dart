import 'package:delivery/Core/Enum/user_type.dart';
import 'package:flutter/material.dart';

class UserModell {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserType userType;
  final String? tokenFCM;
  final String? photo;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  UserModell({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.userType,
    this.tokenFCM,
    this.photo,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an empty user
  factory UserModell.empty() {
    return UserModell(
      id: '',
      name: '',
      email: '',
      phone: '',
      password: '',
      userType: UserType.client,
      isActive: false,
      createdAt: 0,
      updatedAt: 0,
    );
  }

  /// Create from map (e.g. from Firebase or DB)
  factory UserModell.fromMap(String id, Map<String, dynamic> map) {
    return UserModell(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      userType: UserType.fromName(map['type']) ?? UserType.client,
      tokenFCM: map['tokenFCM'],
      photo: map['photo'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
    );
  }

  /// Create from JSON (for orders, no password)
factory UserModell.fromJson(dynamic json) {
  if (json is! Map) return UserModell.empty();

  final map = json.map((key, value) => MapEntry(key.toString(), value));

  return UserModell.fromMap(map['id'] ?? '', map);
  }

  Map<String, dynamic> toMap() {
    return {
        'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'type': userType.name,
      'tokenFCM': tokenFCM,
      'photo': photo,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// For orders JSON - without password
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'type': userType.name,
      'tokenFCM': tokenFCM,
      'photo': photo,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModell copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    UserType? userType,
    String? tokenFCM,
    String? photo,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserModell(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      tokenFCM: tokenFCM ?? this.tokenFCM,
      photo: photo ?? this.photo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helpers for UI
  String get typeText => userType.displayName;
  Color get typeColor => userType.color;
  IconData get typeIcon => userType.icon;
  String get firstLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserContact {
  final String id;
  final String username;
  final String phoneNumber;
  final String nickname;
  final bool isBlocked;

  UserContact._({required this.id, required this.username, required this.phoneNumber, required this.nickname, required this.isBlocked});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
      'nickname': nickname,
      'isBlocked': isBlocked ? 1 : 0,
    };
  }

  factory UserContact.fromMap(String id, Map<String, dynamic> map) {
    return UserContact._(
      id: id,
      username: map['username'],
      phoneNumber: map['phoneNumber'],
      nickname: map['nickname'],
      isBlocked: map['isBlocked'],
    );
  }

  static Map<String, dynamic> insertAsMap({required String username, required String nickname, required String phoneNumber}) {
    return {
      'username': username,
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'isBlocked': false,
      'createdAt': FieldValue.serverTimestamp()
    };
  }

  UserContact copyWith({String? username, String? nickname, String? phoneNumber}) {
    return UserContact._(
      id: id,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nickname: nickname ?? this.nickname,
      isBlocked: isBlocked,
    );
  }
}
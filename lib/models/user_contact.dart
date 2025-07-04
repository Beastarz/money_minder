import 'package:cloud_firestore/cloud_firestore.dart';

class UserContact {
  final String id;
  final String username;
  final String nickname;
  final bool isBlocked;

  UserContact._({required this.id, required this.username, required this.nickname, required this.isBlocked});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'nickname': nickname,
      'isBlocked': isBlocked ? 1 : 0,
    };
  }

  factory UserContact.fromMap(String id, Map<String, dynamic> map) {
    return UserContact._(
      id: id,
      username: map['username'],
      nickname: map['nickname'],
      isBlocked: map['isBlocked'],
    );
  }

  static Map<String, dynamic> insertAsMap({required String username, required String nickname}) {
    return {
      'username': username,
      'nickname': nickname,
      'isBlocked': false,
      'createdAt': FieldValue.serverTimestamp()
    };
  }

  UserContact copyWith({String? username, String? nickname}) {
    return UserContact._(
      id: id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      isBlocked: isBlocked,
    );
  }
}
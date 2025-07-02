class UserContact {
  final int id;
  final String username;
  final String nickname;
  final bool isBlocked;

  UserContact._({required this.id, required this.username, required this.nickname, required this.isBlocked});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'nickname': nickname,
      'is_blocked': isBlocked ? 1 : 0,
    };
  }

  factory UserContact.fromMap(Map<String, dynamic> map) {
    return UserContact._(
      id: map['id'],
      username: map['username'],
      nickname: map['nickname'],
      isBlocked: map['is_blocked'] == 1 ? true : false,
    );
  }

  static Map<String, dynamic> insertAsMap({required String username, required String nickname}) {
    return {
      'username': username,
      'nickname': nickname,
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
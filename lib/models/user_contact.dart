class UserContact {
  final int id;
  final String username;
  final String nickname;

  UserContact._({required this.id, required this.username, required this.nickname});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'nickname': nickname,
    };
  }

  factory UserContact.fromMap(Map<String, dynamic> map) {
    return UserContact._(
      id: map['id'],
      username: map['username'],
      nickname: map['nickname'],
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
    );
  }
}
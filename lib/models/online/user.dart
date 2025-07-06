class User {
  final String uid;
  final String username;
  final String phoneNumber;

  User._({required this.uid, required this.username, required this.phoneNumber});

  factory User.fromMap(Map<String, dynamic> map, String uid) {
    return User._(uid: uid, username: map['username'], phoneNumber: map['phoneNumber'],);
  }
}
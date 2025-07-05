class User {
  final String username;
  final String phoneNumber;

  User._({required this.username, required this.phoneNumber});

  factory User.fromMap(Map<String, dynamic> map) {
    return User._(username: map['username'], phoneNumber: map['phoneNumber']);
  }
}
class User {
  final String uid;
  final String username;
  String phoneNumber;

  User({required this.uid, required this.username, required this.phoneNumber});

  static User get nonUser {
    return User(uid: '0', username: 'non_user', phoneNumber: '');
  }

  factory User.fromMap(Map<String, dynamic>? map, String uid) {
    if (map == null) {
      return nonUser;
    }
    return User(uid: uid, username: map['username'], phoneNumber: map['phoneNumber'],);
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
    };
  }

  void updatePhoneNumber(String newPhoneNumber) {
    phoneNumber = newPhoneNumber;
  }


}
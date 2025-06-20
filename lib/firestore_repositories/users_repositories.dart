import 'package:cloud_firestore/cloud_firestore.dart';

class UsersRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final UsersRepositories instance = UsersRepositories._();
  UsersRepositories._();

  Future<void> createUsername(String uid, String username) async {
    try {
      _db.collection('users').doc(uid).set({
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _db.collection('usernames').doc(username).set({
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getUsername(String uid) async {
    try {
      final DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.get('username');
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkUsernameExist(String username) async {
    try {
      final result = _db.collection('username').doc(username).get().then((doc) {
        return doc.exists;
      });
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
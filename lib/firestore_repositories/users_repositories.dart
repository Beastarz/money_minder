import 'package:cloud_firestore/cloud_firestore.dart';

class UsersRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUsername(String uid, String username) async {
    try {
      _db.collection('users').doc(uid).set({
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
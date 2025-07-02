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

  Future<List<String>> getUsernameByPrefix(String prefix) async {
    if (prefix.isEmpty) {
      return [];
    }
    try {
      prefix = prefix.toLowerCase();
      final QuerySnapshot snapshot = await _db.collection('users')
          .where('username', isGreaterThanOrEqualTo: prefix)
          .where('username', isLessThan: '$prefix\uf8ff')
          .get();
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return snapshot.docs.map((doc) => doc.get('username') as String).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkUsernameExist(String username) async {
    try {
      final snapshot = await _db.collection('users')
          .where('username', isEqualTo: username).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }
}
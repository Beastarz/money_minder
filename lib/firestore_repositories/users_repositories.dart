 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/models/online/user.dart';

class UsersRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final UsersRepositories instance = UsersRepositories._();
  UsersRepositories._();

  Future<void> createUsername(String uid, String phoneNumber, String username) async {
    try {
      _db.collection('users').doc(uid).set({
        'username': username,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getMyUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getUsernameByPrefix(String prefix) async {
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
      return snapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>, doc.id),).toList();
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

  Future<void> deleteMyAccount(String uid) async {
    try {
      _db.collection('users').doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }
}
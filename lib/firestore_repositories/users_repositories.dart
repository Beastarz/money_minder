 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/firestore_repositories/user_contacts_repositories.dart';
import 'package:money_minder/models/online/user.dart';

import 'blocked_users_repositories.dart';

class UsersRepositories {
  final FirebaseFirestore _db;

  UsersRepositories._(this._db);

  static UsersRepositories? _instance;

  static UsersRepositories get instance {
    _instance ??= UsersRepositories._(FirebaseFirestore.instance);
    return _instance!;
  }

  /// Use this in tests to inject a mock Firestore instance
  static void injectInstance(FirebaseFirestore mockDb) {
    _instance = UsersRepositories._(mockDb);
  }


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

  Future<void> updateMyPhoneNumber(String uid, String phoneNumber) async {
    try {
      _db.collection('users').doc(uid).update({
        'phoneNumber': phoneNumber,
      });
      } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMyAccount(String uid) async {
    try {
      await UserContactsRepositories.instance.deleteAllContact(uid);
      await BlockedUsersRepositories.instance.deleteAllBlockedUsers(uid);
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getUserByUsernamePrefix(String prefix) async {
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

  Future<User?> getUserByUsername(String username) async {
    if (username.isEmpty) {
      return null;
    }
    try {
      username = username.toLowerCase();
      final QuerySnapshot snapshot = await _db.collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (snapshot.docs.isEmpty) {
        return null;
      }
      final res = snapshot.docs.first;
      return User.fromMap(res.data() as Map<String, dynamic>, res.id);
    } catch (e) {
      rethrow;
    }
  }

  DocumentReference getUserReference(String uid) {
    return _db.collection('users').doc(uid);
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
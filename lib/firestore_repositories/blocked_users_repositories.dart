import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUsersRepositories {
  final FirebaseFirestore _db;

  // Private constructor with optional db parameter for injection
  BlockedUsersRepositories._privateConstructor([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  static BlockedUsersRepositories _instance = BlockedUsersRepositories._privateConstructor();

  static BlockedUsersRepositories get instance => _instance;

  /// Use this in tests to inject a mock Firestore instance
  static void injectInstance(FirebaseFirestore mockDb) {
    _instance = BlockedUsersRepositories._privateConstructor(mockDb);
  }

  Future<List<String>> getBlockedUsernames(String uid) async {
    try {
      final res = await _db
          .collection('users')
          .doc(uid)
          .collection('blockList')
          .get();
      return res.docs.map((doc) => doc['username'] as String).toList();
    } catch(e) {
      rethrow;
    }
  }

  Future<void> addBlockedUser(String uid, String username) async {
    try {
      await _db.collection('users').doc(uid).collection('blockList').add(
          {'username': username});
    } catch(e) {
      rethrow;
    }
  }

  Future<void> deleteBlockedUser(String uid, String username) async {
    try {
      final ref = await _db
          .collection('users')
          .doc(uid)
          .collection('blockList')
          .where('username', isEqualTo: username)
          .get();
      for (var doc in ref.docs) {
        doc.reference.delete();
      }
    } catch(e) {
      rethrow;
    }
  }

  Future<void> deleteAllBlockedUsers(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection(
          'blockList').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUsersRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  BlockedUsersRepositories._privateConstructor();

  static final BlockedUsersRepositories _instance = BlockedUsersRepositories._privateConstructor();


  static BlockedUsersRepositories get instance => _instance;

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
}
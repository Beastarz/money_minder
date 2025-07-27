import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAccountsRepositories {
  final FirebaseFirestore _db;

  FirebaseAccountsRepositories._(this._db);

  static FirebaseAccountsRepositories? _instance;

  static FirebaseAccountsRepositories get instance {
    _instance ??= FirebaseAccountsRepositories._(FirebaseFirestore.instance);
    return _instance!;
  }

  /// Use this in tests to inject a mock Firestore instance
  static void injectInstance(FirebaseFirestore mockDb) {
    _instance = FirebaseAccountsRepositories._(mockDb);
  }

  Future<List<Map<String, dynamic>>> getAllAccounts(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('accounts').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAllAccounts(String uid, List<Map<String, dynamic>> accounts) async {
    const chunkSize = 500;

    for (int i = 0; i < accounts.length; i += chunkSize) {
      final chunk = accounts.sublist(
          i,
          (i + chunkSize > accounts.length) ? accounts.length : i + chunkSize
      );

      await _db.runTransaction((transaction) async {
        for (final account in chunk) {
          final docRef = _db.collection('users').doc(uid).collection('accounts').doc();
          transaction.set(docRef, Map<String, dynamic>.from(account));
        }
      });
    }
  }

  Future<void> deleteAllAccounts(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection(
          'accounts').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch(e) {
      rethrow;
    }
  }

  // Clean up any injected instances after each test
  static Future<void> resetInstance() async {
    _instance = null;
  }
}
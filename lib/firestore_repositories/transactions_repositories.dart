import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/transactions_repositories.dart';

class FirebaseTransactionsRepositories {
  final FirebaseFirestore _db;

  FirebaseTransactionsRepositories._(this._db);

  static FirebaseTransactionsRepositories? _instance;

  static FirebaseTransactionsRepositories get instance {
    _instance ??= FirebaseTransactionsRepositories._(FirebaseFirestore.instance);
    return _instance!;
  }

  /// Use this in tests to inject a mock Firestore instance
  static void injectInstance(FirebaseFirestore mockDb) {
    _instance = FirebaseTransactionsRepositories._(mockDb);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('transactions').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAllTransactions(String uid, Map<int, String> accountMap, Map<int, String> categoryMap) async {
    try {
      final data = await TransactionsRepositories.instance.getRawTransactions();
      for (var element in data) {
        Map<String, dynamic> transaction = Map<String, dynamic>.from(element);
        transaction['from_account'] = accountMap[element['from_account_id']];
        if (element['type'] == 'transfer') {
          transaction['to_account'] = accountMap[element['to_account_id']];
        } else {
          transaction['to_category'] = categoryMap[element['to_category_id']];
        }
        await _db.collection('users').doc(uid).collection('transactions').add(
            transaction);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllTransactions(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection(
          'transactions').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
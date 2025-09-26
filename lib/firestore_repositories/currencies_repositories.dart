import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/repositories/currency_repositories.dart';

class FirebaseCurrencyRepositories {
  final FirebaseFirestore _db;

  FirebaseCurrencyRepositories._(this._db);

  static FirebaseCurrencyRepositories? _instance;

  static FirebaseCurrencyRepositories get instance {
    _instance ??= FirebaseCurrencyRepositories._(FirebaseFirestore.instance);
    return _instance!;
  }

  /// Use this in tests to inject a mock Firestore instance
  static void injectInstance(FirebaseFirestore mockDb) {
    _instance = FirebaseCurrencyRepositories._(mockDb);
  }

  Future<List<Map<String, dynamic>>> getMainCurrency(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('currency').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addMainCurrency(String uid) async {
    try {
      final data = await CurrencyRepositories.instance.getMainCurrency();
      await _db.collection('users').doc(uid).collection('currency').add(
          {'main_currency': data.toString()});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMainCurrency(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection(
          'currency').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
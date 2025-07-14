import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/budget_repositories.dart';

class FirebaseBudgetsRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseBudgetsRepositories._privateConstructor();

  static final FirebaseBudgetsRepositories _instance = FirebaseBudgetsRepositories
      ._privateConstructor();

  static FirebaseBudgetsRepositories get instance => _instance;

  Future<List<Map<String, dynamic>>> getAllBudgets(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('budgets').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAllBudgets(String uid, Map<int, String> categoryMap) async {
    try {
      final data = await BudgetRepositories.instance.getRawBudgets();
      for (Map<String, dynamic> element in data) {
        Map<String, dynamic> budget = Map<String, dynamic>.from(element);
        budget['category'] = categoryMap[element['category_id']];
        await _db.collection('users').doc(uid).collection('budgets').add(budget);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllBudgets(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('budgets').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCategoriesRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseCategoriesRepositories._privateConstructor();

  static final FirebaseCategoriesRepositories _instance = FirebaseCategoriesRepositories
      ._privateConstructor();

  static FirebaseCategoriesRepositories get instance => _instance;

  Future<List<Map<String, dynamic>>> getAllCategories(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('categories').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAllCategories(String uid, List<Map<String, dynamic>> categories) async {
    try {
      for (Map<String, dynamic> element in categories) {
        await _db.collection('users').doc(uid).collection('categories').add(
            Map<String, dynamic>.from(element));
      }
    } catch(e) {
      rethrow;
    }
  }

  Future<void> deleteAllCategories(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection(
          'categories').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
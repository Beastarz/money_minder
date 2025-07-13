import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/repositories/fast_note_repositories.dart';

class FirebaseFastNotesRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFastNotesRepositories._privateConstructor();

  static final FirebaseFastNotesRepositories _instance = FirebaseFastNotesRepositories
      ._privateConstructor();

  static FirebaseFastNotesRepositories get instance => _instance;

  Future<List<Map<String, dynamic>>> getAllFastNotes(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('fastNotes').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAllFastNotes(String uid, Map<int, String> categoryMap) async {
    try {
      final data = await FastNoteRepositories.instance.getRawFastNotes();
      for (Map<String, dynamic> element in data) {
        Map<String, dynamic> fastNote = Map<String, dynamic>.from(element);
        fastNote['category'] = categoryMap[element['category_id']];
        await _db.collection('users').doc(uid).collection('fastNotes').add(fastNote);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllFastNotes(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('fastNotes').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
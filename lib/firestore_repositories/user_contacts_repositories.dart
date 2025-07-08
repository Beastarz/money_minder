import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/models/online/user_contact.dart';

class UserContactsRepositories {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserContactsRepositories._privateConstructor();

  static final UserContactsRepositories _instance = UserContactsRepositories._privateConstructor();


  static UserContactsRepositories get instance => _instance;

  Future<List<UserContact>> getUserContact(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection('contacts').get();
      return snapshot.docs.map((doc) => UserContact.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addUserContact(String uid, Map<String, dynamic> map) async {
    try {
      await _db.collection('users').doc(uid).collection('contacts').add(map);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserContact(String uid, UserContact userContact) async {
    try {
      final snapshot = _db.collection('users').doc(uid).collection(
          'contacts').doc(userContact.uid);
      await snapshot.set(userContact.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> blockContact(String uid, String username) async {
    try {
      final ref = _db.collection('users').doc(uid).collection('contacts').where('username', isEqualTo: username);
      await ref.get().then((snapshot) => snapshot.docs.first.reference.update({'isBlocked': true}));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unblockContact(String uid, String username) async {
    try {
      final ref = _db.collection('users').doc(uid).collection('contacts').where('username', isEqualTo: username);
      await ref.get().then((snapshot) => snapshot.docs.first.reference.update({'isBlocked': false}));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserContact(String uid, String id) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .doc(id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllContact(String uid) async {
    try {
      final snapshot = await _db.collection('users').doc(uid).collection(
          'contacts').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
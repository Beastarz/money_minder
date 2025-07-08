import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/models/online/transaction_request.dart';

class TransactionRequestRepositories {
  TransactionRequestRepositories._();

  static final TransactionRequestRepositories instance =
  TransactionRequestRepositories._();

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<TransactionRequest>> getSentTransactionRequests(
      String myUid) async {
    try {
      DocumentReference myRef = db.collection('users').doc(myUid);
      final res = await db.collection('transaction_requests').where(
          'sender', isEqualTo: myRef).get();
      if (res.docs.isEmpty) {
        return [];
      }
      return res.docs.map((doc) =>
          TransactionRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionRequest>> getReceivedTransactionRequests(
      String myUid) async {
    try {
      DocumentReference myRef = db.collection('users').doc(myUid);
      final res = await db.collection('transaction_requests').where(
          'receiver', isEqualTo: myRef).get();
      if (res.docs.isEmpty) {
        return [];
      }
      return res.docs.map((doc) =>
          TransactionRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitTransactionRequest(Map<String, dynamic> map) async {
    try {
      await db.collection('transaction_requests').add(map);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptTransactionRequest(String id) async {
    try {
      await db.collection('transaction_requests').doc(id).update({
        'status': 'accepted',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectTransactionRequest(String id) async {
    try {
      await db.collection('transaction_requests').doc(id).update({
        'status': 'rejected',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransactionRequest(String id) async {
    try {
      await db.collection('transaction_requests').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}

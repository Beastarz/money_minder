import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user.dart';

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
      List<TransactionRequest> requests = [];
      for (final doc in res.docs) {
        final receiverRef = doc.data()['receiver'] as DocumentReference;
        final receiver = await receiverRef.get();
        final sender = await myRef.get();
        requests.add(
            TransactionRequest.fromMap(
                doc.data(),
                doc.id,
                User.fromMap(sender.data() as Map<String, dynamic>?, sender.id),
                User.fromMap(receiver.data() as Map<String, dynamic>?, receiver.id)
            )
        );
      }
      requests.sort((a, b) => -a.date.compareTo(b.date));
      return requests;
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

      List<TransactionRequest> requests = [];
      for (final doc in res.docs) {
        final senderRef = doc.data()['sender'] as DocumentReference;
        final receiver = await myRef.get();
        final sender = await senderRef.get();
        requests.add(
            TransactionRequest.fromMap(
                doc.data(),
                doc.id,
                User.fromMap(sender.data() as Map<String, dynamic>?, sender.id),
                User.fromMap(receiver.data() as Map<String, dynamic>?, receiver.id)
            )
        );
      }
      requests.sort((a, b) => -a.date.compareTo(b.date));
      return requests;
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

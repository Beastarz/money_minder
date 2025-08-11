import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user.dart';

class TransactionRequestRepositories {
  /// Use this for the app — default singleton
  static TransactionRequestRepositories get instance {
    _instance ??= TransactionRequestRepositories._();
    return _instance!;
  }

  static TransactionRequestRepositories? _instance;

  /// Allows injection of mock Firestore for tests
  TransactionRequestRepositories._({FirebaseFirestore? db})
      : db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore db;

  Future<List<TransactionRequest>> getSentTransactionRequests(
      String myUid) async {
    try {
      DocumentReference myRef = db.collection('users').doc(myUid);
      final res = await myRef.collection('transactionRequests').where(
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
      final res = await myRef.collection('transactionRequests').where(
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

  // Future<void> submitTransactionRequest(Map<String, dynamic> map) async {
  //   late String id;
  //   try {
  //     await db.collection('transaction_requests').add(map).then((value) => id = value.id);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> submitTransactionRequest(Map<String, dynamic> map) async {
    String senderUid = map['sender'].id;
    String receiverUid = map['receiver'].id;
    late String id;
    try {
      await db.collection('users').doc(senderUid).collection('transactionRequests').add(map).then((value) => id = value.id);
      await db.collection('users').doc(receiverUid).collection('transactionRequests').doc(id).set(map);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptTransactionRequest(String id, String senderId, String receiverId) async {
    try {
      await db.collection('users').doc(senderId).collection('transactionRequests').doc(id).update({
        'status': 'accepted',
      });
      await db.collection('users').doc(receiverId).collection('transactionRequests').doc(id).update({
        'status': 'accepted',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectTransactionRequest(String id, String senderId, String receiverId) async {
    try {
      await db.collection('users').doc(senderId).collection('transactionRequests').doc(id).update({
        'status': 'rejected',
      });
      await db.collection('users').doc(receiverId).collection('transactionRequests').doc(id).update({
        'status': 'rejected',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllTransactionRequest(String uid) async {
    try {
      final snapshot = await db.collection('users').doc(uid).collection(
          'transactionRequests').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}

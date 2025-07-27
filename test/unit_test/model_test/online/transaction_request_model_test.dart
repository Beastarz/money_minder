import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user.dart';
import 'package:money_minder/models/currency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('TransactionRequest', () {
    late User sender;
    late User receiver;
    late Timestamp timestamp;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      sender = User(uid: 'user1', username: 'Alice', phoneNumber: '123456');
      receiver = User(uid: 'user2', username: 'Bob', phoneNumber: '987654');
      timestamp = Timestamp.fromMillisecondsSinceEpoch(1650000000000);
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('fromMap creates correct instance', () {
      final map = {
        'requestType': 'ask',
        'amount': 50.0,
        'currency': 'SGD',
        'status': 'accepted',
        'message': 'Pay me back',
        'date': timestamp,
      };

      final request = TransactionRequest.fromMap(
        map,
        'txn123',
        sender,
        receiver,
      );

      expect(request.id, 'txn123');
      expect(request.sender.uid, sender.uid);
      expect(request.receiver.uid, receiver.uid);
      expect(request.requestType, TransactionRequestType.ask);
      expect(request.amount, 50.0);
      expect(request.currency, Currency.of('SGD'));
      expect(request.status, RequestStatus.accepted);
      expect(request.message, 'Pay me back');
      expect(request.date, timestamp);
    });

    test('submitAsMap returns correct map', () {
      // Option 1: Using fake_cloud_firestore for real DocumentReference objects
      final senderRef = fakeFirestore.collection('users').doc('sender123');
      final receiverRef = fakeFirestore.collection('users').doc('receiver456');

      final map = TransactionRequest.submitAsMap(
        sender: senderRef,
        receiver: receiverRef,
        amount: 88.0,
        currency: Currency.of('SGD'),
        message: 'Dinner split',
        requestType: TransactionRequestType.send,
      );

      expect(map['sender'], senderRef);
      expect(map['receiver'], receiverRef);
      expect(map['amount'], 88.0);
      expect(map['currency'], 'SGD');
      expect(map['requestType'], 'send');
      expect(map['status'], 'pending');
      expect(map['message'], 'Dinner split');
      expect(map['date'], isA<FieldValue>());
    });
  });
}
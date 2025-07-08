import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/models/currency.dart';

enum TransactionRequestType {
  send,
  ask,
}

enum RequestStatus {
  pending,
  accepted,
  rejected,
}

class TransactionRequest {
  final String id;
  final DocumentReference sender;
  final DocumentReference receiver;
  final TransactionRequestType requestType;
  final Currency currency;
  final double amount;
  final RequestStatus status;
  final String message;
  final String date;

  TransactionRequest({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.requestType,
    required this.amount,
    required this.currency,
    required this.status,
    required this.message,
    required this.date
  });

  factory TransactionRequest.fromMap(Map<String, dynamic> map, String id) {
    return TransactionRequest(
      id: id,
      sender: map['senderUsername'],
      receiver: map['receiverUsername'],
      requestType: map['requestType'] == 'send'
          ? TransactionRequestType.send
          : TransactionRequestType.ask,
      amount: map['amount'],
      currency: Currency.of(map['currency']),
      status: map['status'] == 'pending'
          ? RequestStatus.pending
          : map['status'] == 'accepted' ? RequestStatus.accepted : RequestStatus
          .rejected,
      message: map['message'],
      date: map['date'],
    );
  }

  static Map<String , dynamic> submitAsMap({
    required DocumentReference sender,
    required DocumentReference receiver,
    required double amount,
    required Currency currency,
    required String message,
    required TransactionRequestType requestType
  }) {
    return {
      'senderUsername': sender,
      'receiverUsername': receiver,
      'requestType': requestType.name,
      'amount': amount,
      'currency': currency.currency().name,
      'status': 'pending',
      'message': message,
      'date': FieldValue.serverTimestamp(),
    };
  }
}
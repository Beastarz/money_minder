import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/online/user.dart';

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
  final User sender;
  final User receiver;
  final TransactionRequestType requestType;
  final Currency currency;
  final double amount;
  RequestStatus status;
  final String message;
  final Timestamp date;

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

  factory TransactionRequest.fromMap(Map<String, dynamic> map, String id, User sender, User receiver) {
    return TransactionRequest(
      id: id,
      sender: sender,
      receiver: receiver,
      requestType: map['requestType'] == 'send'
          ? TransactionRequestType.send
          : TransactionRequestType.ask,
      amount: map['amount'] is int ? map['amount'].toDouble() : map['amount'],
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
      'sender': sender,
      'receiver': receiver,
      'requestType': requestType.name,
      'amount': amount,
      'currency': currency.currency().name,
      'status': 'pending',
      'message': message,
      'date': FieldValue.serverTimestamp(),
    };
  }
}
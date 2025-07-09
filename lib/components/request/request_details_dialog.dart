import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/online/transaction_request.dart';

class RequestDetailsDialog extends StatelessWidget {
  const RequestDetailsDialog({super.key, required this.request, });

  final TransactionRequest request;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Request Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),)),
              SizedBox(height: 16,),
              Text('Sender: @${request.sender.username}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              Text('Receiver: @${request.receiver.username}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              Text('Amount: ${request.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              Text('Currency: ${request.currency}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              Text('Date: ${formatDate(request.date.toDate(), [d, ' ', M, ', ', yyyy])}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              Text('Status: ${request.status.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              Text('Type: ${request.requestType.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              SizedBox(height: 16,),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Create Transactions'),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
}

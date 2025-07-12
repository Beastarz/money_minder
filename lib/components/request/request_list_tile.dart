import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/request/request_details_dialog.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../firestore_repositories/transaction_request_repositories.dart';

class RequestListTile extends StatefulWidget {
  const RequestListTile({super.key, required this.transactionRequest, required this.displayName, required this.isSender, required this.onReload });

  final TransactionRequest transactionRequest;
  final String displayName;
  final bool isSender;
  final void Function() onReload;

  @override
  State<RequestListTile> createState() => _RequestListTileState();
}

class _RequestListTileState extends State<RequestListTile> {

  void _handleAccept() async {
    await TransactionRequestRepositories.instance.acceptTransactionRequest(widget.transactionRequest.id);
    setState(() {
      widget.transactionRequest.status = RequestStatus.accepted;
    });
  }

  void _handleReject() async {
    await TransactionRequestRepositories.instance.rejectTransactionRequest(widget.transactionRequest.id);
    setState(() {
      widget.transactionRequest.status = RequestStatus.rejected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSender) {
      return ListTile(
        leading: MainIcon(
          icon: Icon(widget.transactionRequest.requestType == TransactionRequestType.send ? Icons.arrow_upward : Icons.arrow_downward),
          color: widget.transactionRequest.requestType == TransactionRequestType.send
              ? Colors.green
              : Colors.red,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.transactionRequest.requestType == TransactionRequestType.send ? 'Send: ' : 'Ask: ',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Flexible(
              child: Text(
                widget.displayName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            ),
          ],
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceText(
              balance: widget.transactionRequest.amount,
              currencyName: widget.transactionRequest.currency.toString(),
              size: 18,
              fontColor: widget.transactionRequest.requestType == TransactionRequestType.send
                  ? Colors.green
                  : Colors.red,
            ),
            Text(formatDate(widget.transactionRequest.date.toDate(), [d, ' ', M, ', ', yyyy]), style: TextStyle(fontSize: 14,)),
          ],
        ),
        trailing: widget.transactionRequest.status ==  RequestStatus.accepted
            ? Text('Accepted', style: TextStyle(fontSize: 16, color: Colors.green),)
            : widget.transactionRequest.status == RequestStatus.rejected
            ? Text('Rejected', style: TextStyle(fontSize: 16, color: Colors.red))
            :Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _handleReject,
                icon: Icon(Icons.close)
              ),
              IconButton(
                onPressed: _handleAccept,
                icon: Icon(Icons.check)
              ),
            ]
        ),
        onTap: () {
          showDialog(context: context, builder: (context) =>
              RequestDetailsDialog(request: widget.transactionRequest, onReload: widget.onReload, isSender: widget.isSender,));
        },
      );
    }

    return ListTile(
      leading: MainIcon(
        icon: Icon(widget.transactionRequest.requestType == TransactionRequestType.send ? Icons.arrow_upward : Icons.arrow_downward),
        color: widget.transactionRequest.requestType == TransactionRequestType.send
            ? Colors.green
            : Colors.red,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.transactionRequest.requestType == TransactionRequestType.send ? 'Received: ' : 'Asked: ',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Flexible(
              child: Text(
                widget.displayName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
          ),
        ],
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BalanceText(
            balance: widget.transactionRequest.amount,
            currencyName: widget.transactionRequest.currency.toString(),
            size: 18,
            fontColor: widget.transactionRequest.requestType == TransactionRequestType.send
                ? Colors.green
                : Colors.red,
          ),
          Text(formatDate(widget.transactionRequest.date.toDate(), [d, ' ', M, ', ', yyyy]), style: TextStyle(fontSize: 14,)),
        ],
      ),
      trailing: widget.transactionRequest.status ==  RequestStatus.accepted
          ? Text('Accepted', style: TextStyle(fontSize: 16, color: Colors.green),)
          : widget.transactionRequest.status == RequestStatus.rejected
          ? Text('Rejected', style: TextStyle(fontSize: 16, color: Colors.red))
          :Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: _handleReject,
                icon: Icon(Icons.close)
            ),
            IconButton(
                onPressed: _handleAccept,
                icon: Icon(Icons.check)
            ),
          ]
      ),
        onTap: () {
          showDialog(context: context, builder: (context) =>
              RequestDetailsDialog(request: widget.transactionRequest, onReload: widget.onReload, isSender: widget.isSender,));
        },
    );
  }
}

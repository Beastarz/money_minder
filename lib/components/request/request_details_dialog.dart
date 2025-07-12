import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_minder/components/categories_page/categories_selection_sheet.dart';
import 'package:money_minder/components/transaction/add_expense_sheet.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/utils/app_message.dart';

class RequestDetailsDialog extends StatelessWidget {
  const RequestDetailsDialog({super.key, required this.request, required this.onReload, required this.isSender, });

  final TransactionRequest request;
  final bool isSender;
  final void Function() onReload;

  @override
  Widget build(BuildContext context) {
    Widget senderDetail = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sender: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            Flexible(child: Text('@${request.sender.username}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text('Phone: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: Text(request.sender.phoneNumber, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
                Flexible(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: request.receiver.phoneNumber));
                        AppMessage.showMessage(context, 'copied!');
                      },
                      icon: Icon(Icons.copy_all_outlined)
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    Widget receiverDetail = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Receiver: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            Flexible(child: Text('@${request.receiver.username}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Phone: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: Text(request.sender.phoneNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
                Flexible(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: request.receiver.phoneNumber));
                          AppMessage.showMessage(context, 'copied!');
                        },
                        icon: Icon(Icons.copy_all_outlined)
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            spacing: 2,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Request Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),)),
              SizedBox(height: 16,),
              isSender ? receiverDetail : senderDetail,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  Flexible(child: Text('${request.currency} ${request.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Request Type: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  Flexible(child: Text(request.requestType.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  Flexible(child: Text(request.status.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  Flexible(child: Text(formatDate(request.date.toDate(), [d, ' ', M, ', ', yyyy]), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
                ],
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Message: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  Flexible(child: Text(request.message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),)),
                ],
              ),
              SizedBox(height: 16,),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          bool isExpense = isSender
                              ? request.requestType == TransactionRequestType.send
                              : request.requestType == TransactionRequestType.ask;
                          return CategoriesSelectionSheet(
                              isExpense: isExpense,
                              onSelect: (Category category) {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return AddExpenseSheet(
                                          mainCurrency: request.currency,
                                          onAddTransactionReload: onReload,
                                          defaultAmount: request.amount,
                                          toCategory: category,
                                          defaultDate: request.date.toDate(),
                                      );
                                    }
                                );
                              },
                          );
                        }
                    );
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

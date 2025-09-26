import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/categories_page/categories_selection_sheet.dart';
import 'package:money_minder/components/transaction/add_expense_sheet.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/utils/app_message.dart';

import '../../firestore_repositories/blocked_users_repositories.dart';
import '../../firestore_repositories/user_contacts_repositories.dart';

class RequestDetailsDialog extends StatelessWidget {
  const RequestDetailsDialog({super.key, required this.request, required this.onReload, required this.isSender, required this.onUserBlocked, });

  final TransactionRequest request;
  final bool isSender;
  final void Function(String) onUserBlocked;
  final void Function() onReload;

  @override
  Widget build(BuildContext context) {
    Widget senderDetail = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sender: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
            Flexible(child: Text('@${request.sender.username}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
          ],
        ),
        request.sender.phoneNumber.isEmpty ? SizedBox.shrink():
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text('Phone: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),)),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: Text(request.sender.phoneNumber, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
                Flexible(
                  child: SizedBox(
                    height: 30.h,
                    width: 30.r,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18.sp,
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
            Text('Receiver: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
            Flexible(child: Text('@${request.receiver.username}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
          ],
        ),
        request.receiver.phoneNumber.isEmpty ? SizedBox.shrink():
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Phone: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: Text(request.receiver.phoneNumber, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
                Flexible(
                  child: SizedBox(
                    height: 30.h,
                    width: 30.w,
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18.sp,
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
      child: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Request Details', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),)),
            SizedBox(height: 16.h,),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6
              ),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 4.h,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isSender ? receiverDetail : senderDetail,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
                        Flexible(child: Text('${request.currency} ${request.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Request Type: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
                        Flexible(child: Text(request.requestType.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
                        Flexible(child: Text(request.status.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
                        Flexible(child: Text(formatDate(request.date.toDate(), [d, ' ', M, ', ', yyyy]), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),)),
                      ],
                    ),
                    SizedBox(height: 8.h,),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Message: ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),),
                          Flexible(child: Text(request.message, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400,),)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h,),
            Stack(
              children: [
                Row(
                  children: [
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        String myUid = FirebaseAuth.instance.currentUser!.uid;
                        String username = isSender ? request.receiver.username : request.sender.username;
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Block User'),
                              content: Text('Are you sure you want to block @$username?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                    try {
                                      await UserContactsRepositories.instance.blockContact(
                                          myUid, username);
                                      await BlockedUsersRepositories.instance.addBlockedUser(
                                          myUid, username);
                                      onUserBlocked(username);
                                    } catch(e) {
                                      if (context.mounted) {
                                        AppMessage.showMessage(context, 'Block Failed');
                                      }
                                    }
                                  },
                                  child: Text('Block', style: TextStyle(color: Colors.red),),
                                ),
                              ],
                            )
                        );
                      },
                      icon: Icon(Icons.person_off_outlined),
                    ),
                  ],
                ),
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
                    child: Text('Create Transactions', style: TextStyle(fontSize: 16.sp),),
                  ),
                ),
              ],
            )
          ]
        ),
      ),
    );
  }
}

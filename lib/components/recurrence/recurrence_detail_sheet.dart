import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/components/recurrence/edit_recurrence_sheet.dart';
import 'package:money_minder/repositories/transaction_helper.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/utils/account_top_card.dart';
import 'package:money_minder/components/transaction/transaction_detail_tile.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/category_top_card.dart';

class RecurrenceDetailSheet extends StatelessWidget {
  const RecurrenceDetailSheet({super.key, required this.recurrence, required this.onEditTransactionReload});

  final Recurrence recurrence;
  final Function() onEditTransactionReload;

  @override
  Widget build(BuildContext context) {
    bool isExpense = recurrence.type == TransactionType.expense;
    bool isTransfer = recurrence.type == TransactionType.transfer;

    AccountTopCard fromAccountCard = AccountTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topLeft: isExpense || isTransfer,
      initialAccount: recurrence.fromAccount,
      isTappable: false,
      onPressed: (a) {},
    );

    Widget toAccountCard = recurrence.toAccount == null ? SizedBox.shrink() :AccountTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topRight: true,
      initialAccount: recurrence.toAccount!,
      isTappable: false,
      onPressed: (a) {},
    );

    Widget toCategoryCard = recurrence.toCategory == null ? SizedBox.shrink() : CategoryTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topRight: isExpense,
      initialCategory: recurrence.toCategory!,
      isTappable: false,
      onPressed: (c) {},
    );

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.secondary,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSize.borderRadius)
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSize.borderRadius)
                ),
              ),
              child: Row(
                  children: isTransfer
                      ? [fromAccountCard, toAccountCard]
                      : isExpense
                      ? [fromAccountCard, toCategoryCard]
                      : [toCategoryCard, fromAccountCard]
              ),
            ),
            Container(
                padding: EdgeInsets.all(AppSize.bigPadding.r),
                child: Column(
                  children: [
                    BalanceText(
                      balance: recurrence.amount,
                      currencyName: recurrence.currency.toString(),
                      size: 30,
                    ),
                    recurrence.recurrenceType == RecurrenceType.none ? SizedBox.shrink() :
                      Text('Recurrence: ${recurrence.recurrenceType.name}'),
                    recurrence.note == '' ? Container() : Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: Text(
                          recurrence.note,
                          style: TextStyle(
                            fontSize: 18.sp,
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0 ,8.h, 0, 8.h),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          TransactionDetailTile(
                              label: 'Edit',
                              icon: Icon(Icons.edit, color: Colors.amber, size: 32.sp,),
                              onPressed: () {
                                Navigator.pop(context);
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return EditRecurrenceSheet(onEditTransactionReload: onEditTransactionReload, oldRecurrence: recurrence);
                                    }
                                );
                              }
                          ),
                          TransactionDetailTile(
                              label: 'Delete',
                              icon: Icon(Icons.delete, color: Colors.redAccent, size: 32.sp,),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                          title: Text('Delete Transaction'),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text('Are you sure you want to delete this transaction?'),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      () async {
                                                        await (recurrence.type == TransactionType.transfer
                                                            ? TransactionHelper.deleteTransfer(recurrence)
                                                            : TransactionHelper.deleteExpense(recurrence));
                                                        onEditTransactionReload();
                                                      }();
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Delete', style: TextStyle(color: Colors.red),)
                                                )
                                              ],
                                            )
                                          ]
                                      );
                                    }
                                );
                              }
                          ),
                          recurrence.recurrenceType == RecurrenceType.none ? SizedBox.shrink() : TransactionDetailTile(
                            label: 'Skip',
                            icon: Icon(Icons.skip_next_outlined, size: 32.sp,),
                            onPressed: () {
                              () async {
                                await RecurrenceRepositories.instance.updateRecurrence(recurrence.increment());
                                onEditTransactionReload();
                              } ();
                              Navigator.pop(context);
                            }
                          ),
                          TransactionDetailTile(
                              label: 'Add Now',
                              icon: Icon(Icons.download_outlined, size: 32.sp,),
                              onPressed: () {
                                () async {
                                  if (recurrence.type == TransactionType.transfer) {
                                    await TransactionHelper.proceedTransfer(recurrence.date, recurrence.fromAccount.id, recurrence.toAccount!.id, recurrence.amount, recurrence.currency, recurrence.note);
                                  } else {
                                    await TransactionHelper.proceedExpense(recurrence.date, recurrence.fromAccount.id, recurrence.toCategory!, recurrence.amount, recurrence.currency, recurrence.note);
                                  }
                                  if (recurrence.recurrenceType != RecurrenceType.none) {
                                    await RecurrenceRepositories.instance.updateRecurrence(recurrence.increment());
                                  } else {
                                    await RecurrenceRepositories.instance.deleteRecurrence(recurrence.id);
                                  }
                                  onEditTransactionReload();
                                } ();
                                Navigator.pop(context);
                              }
                          ),
                        ],
                      ),
                    ),
                    Text(formatDate(recurrence.date, [DD, ', ', dd, ' ', M,' ', yyyy]), style: TextStyle(fontSize: AppSize.heading3.sp),)
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}

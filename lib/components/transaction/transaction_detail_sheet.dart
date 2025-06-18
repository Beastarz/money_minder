import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/transaction/edit_expense_sheet.dart';
import 'package:money_minder/components/transaction/edit_transfer_sheet.dart';
import 'package:money_minder/components/transaction/transaction_helper.dart';
import 'package:money_minder/utils/account_top_card.dart';
import 'package:money_minder/components/transaction/transaction_detail_tile.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/category_top_card.dart';

class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({super.key, required this.transaction, required this.onEditTransactionReload});

  final Transaction transaction;
  final Function() onEditTransactionReload;

  @override
  Widget build(BuildContext context) {
    bool isExpense = transaction.type == TransactionType.expense;
    bool isTransfer = transaction.type == TransactionType.transfer;

    AccountTopCard fromAccountCard = AccountTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topLeft: isExpense || isTransfer,
      initialAccount: transaction.fromAccount,
      isTappable: false,
      onPressed: (a) {},
    );
    
    Widget toAccountCard = transaction.toAccount == null ? SizedBox.shrink() :AccountTopCard(
        width: MediaQuery.of(context).size.width * 0.5,
        topRight: true,
        initialAccount: transaction.toAccount!, 
        isTappable: false,
        onPressed: (a) {},
    );
    
    Widget toCategoryCard = transaction.toCategory == null ? SizedBox.shrink() : CategoryTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topRight: isExpense,
      initialCategory: transaction.toCategory!,
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
              padding: EdgeInsets.all(AppSize.bigPadding),
              child: Column(
                children: [
                  BalanceText(
                    balance: transaction.amount,
                    currencyName: transaction.currency.toString(),
                    size: 30,
                  ),
                  transaction.note == '' ? Container() : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      transaction.note,
                      style: TextStyle(
                        fontSize: 18,
                      )
                    ),
                  ),
                  Wrap(
                    spacing: 16,
                    children: [
                      TransactionDetailTile(
                          label: 'Edit',
                          icon: Icon(Icons.edit, color: Colors.amber,),
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return transaction.type == TransactionType.transfer
                                    ? EditTransferSheet(
                                    onAddTransactionReload: onEditTransactionReload,
                                    oldTransaction: transaction)
                                    : EditExpenseSheet(
                                    onEditTransactionReload: onEditTransactionReload,
                                    oldTransaction: transaction
                                );
                              }
                            );
                          }
                      ),
                      TransactionDetailTile(
                          label: 'Delete',
                          icon: Icon(Icons.delete, color: Colors.redAccent,),
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
                                                  await (transaction.type == TransactionType.transfer
                                                      ? TransactionHelper.deleteTransfer(transaction)
                                                      : TransactionHelper.deleteExpense(transaction));
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
                    ],
                  ),
                  Text(formatDate(transaction.date, [DD, ', ', dd, ' ', M,' ', yyyy]),)
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

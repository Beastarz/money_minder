import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/transaction/transaction_detail_sheet.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../models/transaction.dart';
import '../../style/app_color.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transactions, required this.onTransactionReload});

  final List<Transaction> transactions;
  final Function() onTransactionReload;


  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty ? Container() :
      Container(
        width: MediaQuery.of(context).size.width*0.9,
        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.secondary),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Text(
                    formatDate(transactions[0].date, [dd, ' ', MM.toUpperCase(),' ', yyyy],),
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: BalanceText(
                    balance: _getTransactionBalance(),
                    currencyName: transactions[0].mainCurrency.toString(),
                    mainAxisAlignment: MainAxisAlignment.center,
                    showColor: true,
                  ),
                )
              ],
            ),
            Divider(color: AppColor.secondary, indent: 8, endIndent: 8,),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                Transaction transaction = transactions[index];
                return ListTile(
                  leading: transaction.toCategory == null
                      ? MainIcon(icon: transaction.toAccount!.icon, color: transaction.toAccount!.color, isRound: false, size: 36,)
                      : MainIcon(icon: transaction.toCategory!.icon, color: transaction.toCategory!.color, size: 36,),
                  title: Text(
                    transaction.toCategory == null ? transaction.toAccount!.name : transaction.toCategory!.label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 2,
                        children: [
                          Icon(transaction.fromAccount.icon.icon, size: 17,),
                          Flexible(
                            child: Text(
                              transaction.fromAccount.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      transaction.note == '' ? SizedBox.shrink()
                          :Text(
                            transaction.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BalanceText(
                        balance: transaction.toCategory != null
                            ? transaction.toCategory!.isExpense
                            ? -transaction.mainAmount
                            : transaction.mainAmount
                            : transaction.mainAmount,
                        currencyName: transaction.mainCurrency.toString(),
                        mainAxisAlignment: MainAxisAlignment.end,
                        showColor: transaction.type != TransactionType.transfer,
                        size: 18,
                      ),
                      transaction.mainCurrency.toString() == transaction.currency.toString() ? SizedBox.shrink() :
                      BalanceText(
                        balance: transaction.toCategory != null
                            ? transaction.toCategory!.isExpense
                            ? -transaction.amount
                            : transaction.amount
                            : transaction.amount,
                        currencyName: transaction.currency.toString(),
                        mainAxisAlignment: MainAxisAlignment.end,
                        showColor: transaction.type != TransactionType.transfer,
                        size: 16,
                      ),
                    ],
                  ),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return TransactionDetailSheet(transaction: transaction, onEditTransactionReload: onTransactionReload,);
                    }
                  ),
                );
              }

            ),
          ],
        ),
      );
  }

  double _getTransactionBalance() {
    double res = 0;
    for (Transaction t in transactions) {
      if (t.type == TransactionType.expense) {
        res -= t.mainAmount;
      } else if (t.type == TransactionType.income) {
        res += t.mainAmount;
      }
    }
    return res;
  }
}

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/recurrence/recurrence_detail_sheet.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/utils/balance_text.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../models/transaction.dart';
import '../../style/app_color.dart';

class RecurrenceTile extends StatelessWidget {
  const RecurrenceTile({super.key, required this.recurrences, required this.onTransactionReload});

  final List<Recurrence> recurrences;
  final Function() onTransactionReload;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0,8, 0, 8),
      child: recurrences.isEmpty ? Container() :
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
                    formatDate(recurrences[0].date, [dd, ' ', MM.toUpperCase(),' ', yyyy],),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: BalanceText(
                    balance: _getTransactionBalance(),
                    currencyName: recurrences[0].mainCurrency.toString(),
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
                itemCount: recurrences.length,
                itemBuilder: (context, index) {
                  Recurrence recurrence = recurrences[index];
                  return ListTile(
                    leading: recurrence.toCategory == null
                        ? MainIcon(icon: recurrence.toAccount!.icon, color: recurrence.toAccount!.color.withValues(alpha: 0.7), isRound: false, size: 36,)
                        : MainIcon(icon: recurrence.toCategory!.icon, color: recurrence.toCategory!.color.withValues(alpha: 0.7), size: 36,),
                    title: Text(
                      recurrence.toCategory == null ? recurrence.toAccount!.name : recurrence.toCategory!.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.black54
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 2,
                          children: [
                            Icon(recurrence.fromAccount.icon.icon, size: 17,),
                            Flexible(
                              child: Text(
                                recurrence.fromAccount.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black54
                                ),
                              ),
                            ),
                          ],
                        ),
                        recurrence.recurrenceType == RecurrenceType.none
                            ? recurrence.note == ''
                            ? SizedBox.shrink()
                            :Text(
                              recurrence.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black54),
                            )
                            : Text(
                              'Recurrence: ${recurrence.recurrenceType.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black54),
                            )
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BalanceText(
                          balance: recurrence.toCategory != null
                              ? recurrence.toCategory!.isExpense
                              ? -recurrence.mainAmount
                              : recurrence.mainAmount
                              : recurrence.mainAmount,
                          currencyName: recurrence.mainCurrency.toString(),
                          mainAxisAlignment: MainAxisAlignment.end,
                          showColor: recurrence.type != TransactionType.transfer,
                          size: 18,
                        ),
                        recurrence.mainCurrency.toString() == recurrence.currency.toString() ? SizedBox.shrink() :
                        BalanceText(
                          balance: recurrence.toCategory != null
                              ? recurrence.toCategory!.isExpense
                              ? -recurrence.amount
                              : recurrence.amount
                              : recurrence.amount,
                          currencyName: recurrence.currency.toString(),
                          mainAxisAlignment: MainAxisAlignment.end,
                          showColor: recurrence.type != TransactionType.transfer,
                          size: 16,
                        ),
                      ],
                    ),
                    onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return RecurrenceDetailSheet(recurrence: recurrence, onEditTransactionReload: onTransactionReload,);
                        }
                    ),
                  );
                }

            ),
          ],
        ),
      ),
    );
  }

  double _getTransactionBalance() {
    double res = 0;
    for (Transaction t in recurrences) {
      if (t.type == TransactionType.expense) {
        res -= t.mainAmount;
      } else if (t.type == TransactionType.income) {
        res += t.mainAmount;
      }
    }
    return res;
  }
}

import 'package:flutter/material.dart';
import 'package:money_minder/components/transaction/transaction_tile.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/utils/balance_text.dart';

import '../../models/transaction.dart';

class TransactionsContent extends StatelessWidget {
  const TransactionsContent({super.key, required this.transactions, required this.initialBalance, required this.finalBalance, required this.mainCurrency,});

  final List<Transaction> transactions;
  final double initialBalance;
  final double finalBalance;
  final Currency mainCurrency;

  @override
  Widget build(BuildContext context) {
    List<List<Transaction>> groupedTransactionsByDate = groupTransactionsByDate(transactions);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03, vertical: 16),
      child: Column(
        spacing: 16,
        children: <Widget> [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: MediaQuery.of(context).size.width*0.05,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColor.secondary
                ),
                width: MediaQuery.of(context).size.width * 0.40,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Starting Balance'),
                    BalanceText(
                      balance: initialBalance,
                      currencyName: mainCurrency.toString(),
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ]
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColor.secondary
                ),
                width: MediaQuery.of(context).size.width * 0.40,
                height: 80,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ending Balance'),
                      BalanceText(
                        balance: finalBalance,
                        currencyName: mainCurrency.toString(),
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ]
                ),
              )
            ],
          ),
        ] + groupedTransactionsByDate.reversed.map((t) => TransactionTile(transactions: t)).toList(),
      ),
    );
  }

  List<List<Transaction>> groupTransactionsByDate(List<Transaction> transactions) {
    if (transactions.isEmpty) return [];
    List<List<Transaction>> res = [];
    List<Transaction> temp = [transactions.first];
    for (Transaction t in transactions.sublist(1)) {
      if (t.date.isAtSameMomentAs(temp.last.date)) {
        temp.add(t);
      } else {
        res.add(temp);
        temp = [t];
      }
    }
    if (temp.isNotEmpty) res.add(temp);
    return res;
  }
}

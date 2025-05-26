import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';

class Transaction {
  int id;
  DateTime date;
  String type;
  Account fromAccount;
  Account? toAccount;
  int? toCategoryId;
  double amount;
  Currency currency;
  double amount2;
  Currency currency2;
  String note;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.fromAccount,
    required this.toAccount,
    required this.toCategoryId,
    required this.amount,
    required this.currency,
    required this.amount2,
    required this.currency2,
    required this.note,
  });

  /// use this to convert map to transaction
  factory Transaction.fromMap(Map<String, dynamic> map, Account fromAccount, Account? toAccount) {
    return Transaction(
      id: map['id'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      fromAccount: fromAccount,
      toAccount: toAccount,
      toCategoryId: map['to_category_id'],
      amount: map['amount'],
      currency: Currency.of(map['currency']),
      amount2: map['amount2'],
      currency2: Currency.of(map['currency2']),
      note: map['note'],
    );
  }

  /// use this to group transactions by date
  static List<List<Transaction>> groupTransactionsByDate(List<Transaction> transactions, List<DateTime> startDates) {
    List<List<Transaction>> groupedTransactions = [];
    for (int i = 0; i < startDates.length-1 ; i++) {
      groupedTransactions.add(
          transactions.where(
                  (transaction) =>
                  (transaction.date.isAfter(startDates[i]) || transaction.date.isAtSameMomentAs(startDates[i]))
                          && transaction.date.isBefore(startDates[i+1])
          ).toList());
    }
    return groupedTransactions;
  }

  /// temp
  @override
  String toString() {
    return 'from: ' + fromAccount.name + ' ' + amount.toStringAsFixed(2) + ' ' + (toAccount == null ? 'null' : toAccount!.name);
  }

}
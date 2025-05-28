import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';

class Transaction {
  int id;
  DateTime date;
  String type;
  Account fromAccount;
  Account? toAccount;
  Category? toCategory;
  double amount;
  Currency currency;
  Currency mainCurrency;
  String note;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.fromAccount,
    required this.toAccount,
    required this.toCategory,
    required this.amount,
    required this.currency,
    required this.mainCurrency,
    required this.note,
  });

  get mainAmount => Currency.convert(currency, mainCurrency, amount);

  /// use this to convert map to transaction
  factory Transaction.fromMap(Map<String, dynamic> map, Account fromAccount, Account? toAccount, Category? category, Currency mainCurrency) {
    return Transaction(
      id: map['id'],
      date: DateTime.parse(map['date']),
      type: map['type'],
      fromAccount: fromAccount,
      toAccount: toAccount,
      toCategory: category,
      amount: map['amount'],
      currency: Currency.of(map['currency']),
      mainCurrency: mainCurrency,
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
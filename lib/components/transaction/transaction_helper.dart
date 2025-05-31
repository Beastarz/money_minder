import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';

import '../../models/category.dart';
import '../../models/currency.dart';
import '../../models/transaction.dart';

class TransactionHelper {
  TransactionHelper._();

  static Future<void> proceedExpense(DateTime date, Account fromAccount, Category toCategory, double amount, Currency currency, String note) async {
    if (!toCategory.isExpense) {
      return proceedIncome(date, fromAccount, toCategory, amount, currency, note);
    }
    double balance = fromAccount.balance - amount;
    AccountsRepository.instance.updateAccount(fromAccount.copyWith(balance: balance));
    TransactionsRepositories.instance.createTransaction(
        Transaction.insertAsMap(
            date: date,
            type: TransactionType.expense,
            fromAccountId: fromAccount.id,
            toCategoryId: toCategory.id,
            amount: amount,
            currency: currency,
            note: note
        ));
  }

  static Future<void> proceedIncome(DateTime date, Account fromAccount, Category toCategory, double amount, Currency currency, String note) async {
    if (toCategory.isExpense) {
      proceedExpense(date, fromAccount, toCategory, amount, currency, note);
    }
    double balance = fromAccount.balance + amount;
    AccountsRepository.instance.updateAccount(fromAccount.copyWith(balance: balance));
    TransactionsRepositories.instance.createTransaction(
        Transaction.insertAsMap(
            date: date,
            type: TransactionType.income,
            fromAccountId: fromAccount.id,
            toCategoryId: toCategory.id,
            amount: amount,
            currency: currency,
            note: note
        ));
  }
}
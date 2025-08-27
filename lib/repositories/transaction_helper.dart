import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';

import '../models/category.dart';
import '../models/currency.dart';
import '../models/transaction.dart';

class TransactionHelper {
  TransactionHelper._();

  static Future<void> proceedExpense(DateTime date, int fromAccountId, Category toCategory, double amount, Currency currency, String note) async {
    if (!toCategory.isExpense) {
      return proceedIncome(date, fromAccountId, toCategory, amount, currency, note);
    }

    Account fromAccount = await AccountsRepositories.instance.getAccountById(fromAccountId);

    double balance = fromAccount.balance - Currency.convert(currency, fromAccount.currency, amount);
    AccountsRepositories.instance.updateAccount(fromAccount.copyWith(balance: balance));
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

  static Future<void> proceedIncome(DateTime date, int fromAccountId, Category toCategory, double amount, Currency currency, String note) async {
    if (toCategory.isExpense) {
      proceedExpense(date, fromAccountId, toCategory, amount, currency, note);
    }

    Account fromAccount = await AccountsRepositories.instance.getAccountById(fromAccountId);

    double balance = fromAccount.balance + Currency.convert(currency, fromAccount.currency, amount);
    AccountsRepositories.instance.updateAccount(fromAccount.copyWith(balance: balance));
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



  static Future<void> editExpense(Transaction oldTransaction, DateTime date, int fromAccountId, Category toCategory, double amount, Currency currency, String note) async {
    await undoTransaction(oldTransaction);
    await TransactionsRepositories.instance.deleteTransaction(oldTransaction.id);
    await proceedExpense(date, fromAccountId, toCategory, amount, currency, note);
  }

  static Future<void> deleteExpense(Transaction oldTransaction, {bool isRecurrence = false}) async {
    await undoTransaction(oldTransaction);
    if (isRecurrence) {
      await RecurrenceRepositories.instance.deleteRecurrence(oldTransaction.id);
    }
    await TransactionsRepositories.instance.deleteTransaction(oldTransaction.id);
  }

  static Future<void> undoTransaction(Transaction transaction) async {
    Account fromAccount = await AccountsRepositories.instance.getAccountById(transaction.fromAccount.id);

    double balance = Currency.convert(transaction.currency, fromAccount.currency, transaction.amount);
    if (transaction.type == TransactionType.income) {
      await AccountsRepositories.instance.updateAccount(fromAccount.copyWith(balance: fromAccount.balance - balance));
    } else {
      await AccountsRepositories.instance.updateAccount(fromAccount.copyWith(balance: fromAccount.balance + balance));
    }
  }

  static Future<void> proceedTransfer(DateTime date, int fromAccountId, int toAccountId, double amount, Currency currency, String note) async {

    Account fromAccount = await AccountsRepositories.instance.getAccountById(fromAccountId);
    Account toAccount = await AccountsRepositories.instance.getAccountById(toAccountId);

    double balanceFrom = Currency.convert(currency, fromAccount.currency, amount);
    double balanceTo = Currency.convert(currency, toAccount.currency, amount);

    await AccountsRepositories.instance.updateAccount(fromAccount.copyWith(balance: fromAccount.balance - balanceFrom));
    AccountsRepositories.instance.updateAccount(toAccount.copyWith(balance: toAccount.balance + balanceTo));
    TransactionsRepositories.instance.createTransaction(
        Transaction.insertAsMap(
            date: date,
            type: TransactionType.transfer,
            fromAccountId: fromAccount.id,
            toAccountId: toAccount.id,
            amount: amount,
            currency: currency,
            note: note
        )
    );
  }

  static Future<void> updateTransfer(Transaction oldTransaction, DateTime date, int fromAccountId, int toAccountId, double amount, Currency currency, String note) async {
    await undoTransfer(oldTransaction);
    await TransactionsRepositories.instance.deleteTransaction(oldTransaction.id);
    await proceedTransfer(date, fromAccountId, toAccountId, amount, currency, note);
  }

  static Future<void> undoTransfer(Transaction transaction) async {
    if (transaction.toAccount == null || transaction.type != TransactionType.transfer) {
      return;
    }
    Account fromAccount = await AccountsRepositories.instance.getAccountById(transaction.fromAccount.id);
    Account toAccount = await AccountsRepositories.instance.getAccountById(transaction.toAccount!.id);

    double balanceFrom = Currency.convert(transaction.currency, fromAccount.currency, transaction.amount);
    double balanceTo = Currency.convert(transaction.currency, toAccount.currency, transaction.amount);

    AccountsRepositories.instance.updateAccount(fromAccount.copyWith(balance: fromAccount.balance + balanceFrom));
    AccountsRepositories.instance.updateAccount(toAccount.copyWith(balance: toAccount.balance - balanceTo));
  }

  static Future<void> deleteTransfer(Transaction oldTransaction, {bool isRecurrence = false}) async {
    await undoTransfer(oldTransaction);
    if (isRecurrence) {
      await RecurrenceRepositories.instance.deleteRecurrence(oldTransaction.id);
    }
    await TransactionsRepositories.instance.deleteTransaction(oldTransaction.id);
  }

  static DateTime getEarliestStartDate(List<Transaction> transaction) {
    if (transaction.isEmpty) {
      return DateTime.now();
    }
    DateTime startDate = transaction.first.date;
    for (Transaction t in transaction) {
      if (t.date.isBefore(startDate)) {
        startDate = t.date;
      }
    }
    return startDate;
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/transaction.dart';

void main() {
  group('Transaction', () {
    late Account fromAccount;
    late Account toAccount;
    late Category category;
    late Currency sgdCurrency;
    late Currency myrCurrency;
    late Currency mainCurrency;

    setUp(() {
      sgdCurrency = Currency.of('SGD');
      myrCurrency = Currency.of('MYR');
      mainCurrency = sgdCurrency;

      fromAccount = Account(
        id: 1,
        name: 'Checking Account',
        balance: 1000.0,
        icon: Icon(Icons.account_balance_wallet),
        color: Colors.blue,
        description: '',
        isMain: true,
        isIncludesInTotal: true,
        type: AccountType.accounts,
        currency: sgdCurrency,
        position: 0,
      );

      toAccount = Account(
        id: 2,
        name: 'Savings Account',
        balance: 500.0,
        icon: Icon(Icons.savings),
        color: Colors.green,
        description: '',
        isMain: false,
        isIncludesInTotal: true,
        type: AccountType.savings,
        currency: sgdCurrency,
        position: 1,
      );

      category = Category(
        id: 101,
        label: 'Groceries',
        position: 0,
        icon: Icon(Icons.shopping_basket),
        color: Colors.red,
        isExpense: true,
      );
    });

    // Test case for the Transaction constructor
    test('Transaction constructor initializes properties correctly', () {
      final now = DateTime.now();
      final transactionDate = DateTime(now.year, now.month, now.day); // Should strip time

      final transaction = Transaction(
        id: 1,
        date: now,
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: category,
        amount: 50.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Weekly groceries',
      );

      expect(transaction.id, 1);
      expect(transaction.date, transactionDate); // Check if time is stripped
      expect(transaction.type, TransactionType.expense);
      expect(transaction.fromAccount, fromAccount);
      expect(transaction.toAccount, isNull);
      expect(transaction.toCategory, category);
      expect(transaction.amount, 50.0);
      expect(transaction.currency, sgdCurrency);
      expect(transaction.mainCurrency, mainCurrency);
      expect(transaction.note, 'Weekly groceries');
    });

    // Test for mainAmount getter
    test('mainAmount getter converts amount to main currency correctly', () {
      final transactionSGD = Transaction(
        id: 1,
        date: DateTime.now(),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: category,
        amount: 100.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Test',
      );

      // If mainCurrency is SGD and transaction currency is SGD, conversion rate is 1
      expect(transactionSGD.mainAmount, 100.0);

      final transactionMYR = Transaction(
        id: 2,
        date: DateTime.now(),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: category,
        amount: 100.0, // 100 MYR
        currency: myrCurrency,
        mainCurrency: sgdCurrency, // Main currency is SGD
        note: 'Test MYR',
      );

      expect(transactionMYR.mainAmount, closeTo(Currency.convert(myrCurrency, sgdCurrency, 100), 0.01));
    });

    // Test for fromMap factory constructor
    test('Transaction.fromMap creates a Transaction object from a map', () {
      final transactionMap = {
        'id': 3,
        'date': '2025-06-13T10:00:00.000Z',
        'type': 'income',
        'from_account_id': 1,
        'to_account_id': null,
        'to_category_id': 101,
        'amount': 200.0,
        'currency': 'SGD',
        'note': 'Freelance payment',
      };

      final transaction = Transaction.fromMap(
        transactionMap,
        fromAccount,
        null, // toAccount
        category, // toCategory
        mainCurrency,
      );

      expect(transaction.id, 3);
      expect(transaction.date, DateTime(2025, 6, 13));
      expect(transaction.type, TransactionType.income);
      expect(transaction.fromAccount, fromAccount);
      expect(transaction.toAccount, isNull);
      expect(transaction.toCategory, category);
      expect(transaction.amount, 200.0);
      expect(transaction.currency.currency().name, 'sgd');
      expect(transaction.mainCurrency, mainCurrency);
      expect(transaction.note, 'Freelance payment');
    });

    // Test for toMap method
    test('toMap converts Transaction object to a map correctly', () {
      final transaction = Transaction(
        id: 4,
        date: DateTime(2025, 6, 14),
        type: TransactionType.transfer,
        fromAccount: fromAccount,
        toAccount: toAccount,
        toCategory: null,
        amount: 150.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Transfer to savings',
      );

      final map = transaction.toMap();

      expect(map['id'], 4);
      expect(map['date'], '2025-06-14T00:00:00.000');
      expect(map['type'], 'transfer');
      expect(map['from_account_id'], fromAccount.id);
      expect(map['to_account_id'], toAccount.id);
      expect(map['to_category_id'], isNull);
      expect(map['amount'], 150.0);
      expect(map['currency'], 'sgd');
      expect(map['note'], 'Transfer to savings');
    });

    // Test for insertAsMap static method
    group('insertAsMap', () {
      test('insertAsMap creates a map for insertion correctly with toAccountId', () {
        final date = DateTime.now();
        final map = Transaction.insertAsMap(
          date: date,
          type: TransactionType.transfer,
          fromAccountId: 1,
          toAccountId: 2,
          toCategoryId: null,
          amount: 100.0,
          currency: sgdCurrency,
          note: 'Transfer funds',
        );

        expect(map['date'], DateTime(date.year, date.month, date.day).toIso8601String());
        expect(map['type'], 'transfer');
        expect(map['from_account_id'], 1);
        expect(map['to_account_id'], 2);
        expect(map['to_category_id'], isNull);
        expect(map['amount'], 100.0);
        expect(map['currency'], 'sgd');
        expect(map['note'], 'Transfer funds');
      });

      test('insertAsMap creates a map for insertion correctly with toCategoryId', () {
        final date = DateTime.now();
        final map = Transaction.insertAsMap(
          date: date,
          type: TransactionType.expense,
          fromAccountId: 1,
          toAccountId: null,
          toCategoryId: 101,
          amount: 50.0,
          currency: sgdCurrency,
          note: 'Bought coffee',
        );

        expect(map['date'], DateTime(date.year, date.month, date.day).toIso8601String());
        expect(map['type'], 'expense');
        expect(map['from_account_id'], 1);
        expect(map['to_account_id'], isNull);
        expect(map['to_category_id'], 101);
        expect(map['amount'], 50.0);
        expect(map['currency'], 'sgd');
        expect(map['note'], 'Bought coffee');
      });

      test('insertAsMap throws exception if both toAccountId and toCategoryId are null', () {
        final date = DateTime.now();
        expect(
              () => Transaction.insertAsMap(
            date: date,
            type: TransactionType.expense,
            fromAccountId: 1,
            toAccountId: null,
            toCategoryId: null,
            amount: 50.0,
            currency: sgdCurrency,
            note: 'Invalid transaction',
          ),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('toAccountId and toCategoryId cannot be null at the same time'))),
        );
      });
    });

    // Test for copyWith method
    test('copyWith creates a new Transaction object with updated properties', () {
      final originalTransaction = Transaction(
        id: 5,
        date: DateTime(2025, 1, 1),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: category,
        amount: 75.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Original note',
      );

      final newDate = DateTime(2025, 1, 2);
      final updatedAmount = 80.0;
      final updatedNote = 'Updated note';
      final updatedCurrency = myrCurrency;

      final copiedTransaction = originalTransaction.copyWith(
        date: newDate,
        amount: updatedAmount,
        note: updatedNote,
        currency: updatedCurrency,
      );

      expect(copiedTransaction.id, originalTransaction.id);
      expect(copiedTransaction.date, newDate);
      expect(copiedTransaction.type, originalTransaction.type);
      expect(copiedTransaction.fromAccount, originalTransaction.fromAccount);
      expect(copiedTransaction.toAccount, originalTransaction.toAccount);
      expect(copiedTransaction.toCategory, originalTransaction.toCategory);
      expect(copiedTransaction.amount, updatedAmount);
      expect(copiedTransaction.currency, updatedCurrency);
      expect(copiedTransaction.mainCurrency, originalTransaction.mainCurrency);
      expect(copiedTransaction.note, updatedNote);

      // Ensure original is not modified
      expect(originalTransaction.date, DateTime(2025, 1, 1));
      expect(originalTransaction.amount, 75.0);
      expect(originalTransaction.note, 'Original note');
      expect(originalTransaction.currency, sgdCurrency);
    });

    // Test for groupTransactionsByDate static method
    group('groupTransactionsByDate', () {
      late List<Transaction> transactions;

      setUp(() {
        transactions = [
          Transaction(
            id: 1,
            date: DateTime(2025, 6, 1),
            type: TransactionType.expense,
            fromAccount: fromAccount,
            toAccount: null,
            toCategory: category,
            amount: 10.0,
            currency: sgdCurrency,
            mainCurrency: mainCurrency,
            note: 'T1',
          ),
          Transaction(
            id: 2,
            date: DateTime(2025, 6, 2),
            type: TransactionType.expense,
            fromAccount: fromAccount,
            toAccount: null,
            toCategory: category,
            amount: 20.0,
            currency: sgdCurrency,
            mainCurrency: mainCurrency,
            note: 'T2',
          ),
          Transaction(
            id: 3,
            date: DateTime(2025, 6, 2),
            type: TransactionType.income,
            fromAccount: fromAccount,
            toAccount: null,
            toCategory: category,
            amount: 50.0,
            currency: sgdCurrency,
            mainCurrency: mainCurrency,
            note: 'T3',
          ),
          Transaction(
            id: 4,
            date: DateTime(2025, 6, 3),
            type: TransactionType.transfer,
            fromAccount: fromAccount,
            toAccount: toAccount,
            toCategory: null,
            amount: 30.0,
            currency: sgdCurrency,
            mainCurrency: mainCurrency,
            note: 'T4',
          ),
          Transaction(
            id: 5,
            date: DateTime(2025, 6, 4),
            type: TransactionType.expense,
            fromAccount: fromAccount,
            toAccount: null,
            toCategory: category,
            amount: 15.0,
            currency: sgdCurrency,
            mainCurrency: mainCurrency,
            note: 'T5',
          ),
        ];
      });

      test('groups transactions correctly for distinct start dates', () {
        final startDates = [
          DateTime(2025, 6, 1),
          DateTime(2025, 6, 2),
          DateTime(2025, 6, 3),
          DateTime(2025, 6, 4),
          DateTime(2025, 6, 5), // End boundary for the last group
        ];

        final grouped = Transaction.groupTransactionsByDate(transactions, startDates);

        expect(grouped.length, 4); // Should be 4 groups based on 5 startDates (n-1 groups)

        // Group 1: 2025-06-01 to 2025-06-02 (exclusive of 2025-06-02) -> only T1
        expect(grouped[0].length, 1);
        expect(grouped[0].map((t) => t.id), containsAll([1]));

        // Group 2: 2025-06-02 to 2025-06-03 (exclusive of 2025-06-03) -> T2, T3
        expect(grouped[1].length, 2);
        expect(grouped[1].map((t) => t.id), containsAll([2, 3]));

        // Group 3: 2025-06-03 to 2025-06-04 (exclusive of 2025-06-04) -> T4
        expect(grouped[2].length, 1);
        expect(grouped[2].map((t) => t.id), containsAll([4]));

        // Group 4: 2025-06-04 to 2025-06-05 (exclusive of 2025-06-05) -> T5
        expect(grouped[3].length, 1);
        expect(grouped[3].map((t) => t.id), containsAll([5]));
      });

      test('handles empty list of transactions', () {
        final startDates = [
          DateTime(2025, 6, 1),
          DateTime(2025, 6, 2),
        ];
        final grouped = Transaction.groupTransactionsByDate([], startDates);
        expect(grouped.length, 1); // One group, but empty
        expect(grouped[0], isEmpty);
      });

      test('handles transactions outside the given date ranges', () {
        final transactionsOutsideRange = [
          Transaction(
            id: 6,
            date: DateTime(2025, 5, 30),
            type: TransactionType.expense,
            fromAccount: fromAccount,
            toAccount: null,
            toCategory: category,
            amount: 5.0,
            currency: sgdCurrency,
            mainCurrency: mainCurrency,
            note: 'T6',
          ),
          Transaction(
            id: 7,
            date: DateTime(2025, 6, 10),
            type: TransactionType.expense,
            fromAccount: fromAccount,
            toAccount: null,
            toCategory: category,
            amount: 5.0,
            currency: sgdCurrency,
            mainCurrency: mainCurrency,
            note: 'T7',
          ),
        ];

        final startDates = [
          DateTime(2025, 6, 1),
          DateTime(2025, 6, 5),
        ];

        // Combine transactions for this test
        final allTransactions = [...transactions, ...transactionsOutsideRange];
        final grouped = Transaction.groupTransactionsByDate(allTransactions, startDates);

        expect(grouped.length, 1); // Only one group for 2025-06-01 to 2025-06-05
        expect(grouped[0].length, 5); // T1, T2, T3, T4, T5 should be in this group
        expect(grouped[0].map((t) => t.id), containsAll([1, 2, 3, 4, 5]));
        expect(grouped[0].map((t) => t.id), isNot(contains(6)));
        expect(grouped[0].map((t) => t.id), isNot(contains(7)));
      });
    });
  });
}

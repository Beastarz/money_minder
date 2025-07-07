import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';
import 'package:flutter/material.dart';

import 'test.mocks.dart';


void main() {
  late MockDatabaseService mockDatabaseService;
  late MockDatabase mockDatabase;
  late MockAccountsRepositories mockAccountsRepositories;
  late MockCategoriesRepositories mockCategoriesRepositories;
  late MockCurrencyRepositories mockCurrencyRepositories;
  late TransactionsRepositories transactionsRepositories;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDatabase = MockDatabase();
    mockAccountsRepositories = MockAccountsRepositories();
    mockCategoriesRepositories = MockCategoriesRepositories();
    mockCurrencyRepositories = MockCurrencyRepositories();

    // Set up the mock DatabaseService to return the mock Database
    when(mockDatabaseService.database).thenAnswer((_) async => mockDatabase);

    // Inject the mock DatabaseService into the repository for testing
    TransactionsRepositories.setMockDbService(mockDatabaseService);

    // Set the static instances of other repositories to their mocks
    AccountsRepositories.setTestInstance(mockAccountsRepositories);
    CategoriesRepositories.setTestInstance(mockCategoriesRepositories);
    CurrencyRepositories.setTestInstance(mockCurrencyRepositories);

    transactionsRepositories = TransactionsRepositories.instance;
  });

  tearDown(() {
    // Reset the instances after each test to avoid interference
    TransactionsRepositories.resetInstance();
    AccountsRepositories.resetInstance();
    CategoriesRepositories.resetInstance();
    CurrencyRepositories.resetInstance();
  });

  final Icon icon = Icon(Icons.add);
  final Color color = Colors.red;
  final String description = 'test';

  group('TransactionsRepositories', () {
    final currency = Currency.of('sgd');
    final fromAccount = Account(id: 1,
        name: 'Cash',
        balance: 100.0,
        icon: icon,
        color: color,
        description: description,
        isMain: true,
        isIncludesInTotal: true,
        type: AccountType.accounts,
        currency: currency,
        position: 0);

    final toAccount = Account(id: 2,
        name: 'Savings',
        balance: 100.0,
        icon: icon,
        color: color,
        description: description,
        isMain: false,
        isIncludesInTotal: true,
        type: AccountType.savings,
        currency: currency,
        position: 1);

    final toCategory = Category(id: 1,
        name: 'Food',
        position: 0,
        icon: icon,
        color: color,
        isExpense: true);

    test('createTransaction inserts data into the database', () async {
      final transactionMap = Transaction.insertAsMap(
          date: DateTime.parse('2025-06-26'),
          type: TransactionType.expense,
          fromAccountId: 1,
          toCategoryId: 1,
          amount: 5.0,
          currency: currency,
          note: description);

      when(mockDatabase.insert(any, any))
          .thenAnswer((_) async => 1);

      await transactionsRepositories.createTransaction(transactionMap);

      final capturedArgs = verify(mockDatabase.insert('transactions', captureAny)).captured.first as Map<String, dynamic>;
      expect(capturedArgs['amount'], 5.0);
    });

    test('updateTransaction updates data in the database', () async {
      final transaction = Transaction(
        id: 1,
        fromAccount: fromAccount,
        toAccount: toAccount,
        toCategory: null,
        amount: 120.0,
        date: DateTime.parse('2025-06-26'),
        type: TransactionType.transfer,
        note: 'Updated transfer',
        currency: currency,
        mainCurrency: currency,
      );

      when(mockDatabase.update('transactions', transaction.toMap(),
          where: 'id = ?', whereArgs: [transaction.id]))
          .thenAnswer((_) async => 1);

      await transactionsRepositories.updateTransaction(transaction);

      verify(mockDatabase.update('transactions', transaction.toMap(),
          where: 'id = ?', whereArgs: [transaction.id]))
          .called(1);
    });

    group('getTransactions', () {
      test('returns a list of transactions', () async {
        final rawTransactions = [
          {
            'id': 1,
            'from_account_id': 1,
            'to_account_id': null,
            'to_category_id': 1,
            'amount': 5.0,
            'date': '2025-06-25 10:00:00',
            'type': 'expense',
            'note': 'Coffee',
            'currency': 'sgd'
          },
          {
            'id': 2,
            'from_account_id': 1,
            'to_account_id': 2,
            'to_category_id': null,
            'amount': 200.0,
            'date': '2025-06-24 15:30:00',
            'type': 'transfer',
            'note': 'Savings transfer',
            'currency': 'sgd'
          },
        ];

        when(mockDatabase.query('transactions'))
            .thenAnswer((_) async => rawTransactions);
        when(mockAccountsRepositories.getAllAccounts())
            .thenAnswer((_) async => [fromAccount, toAccount]);
        when(mockCategoriesRepositories.getAllCategories())
            .thenAnswer((_) async => [toCategory]);
        when(mockCurrencyRepositories.getMainCurrency())
            .thenAnswer((_) async => currency);

        final result = await transactionsRepositories.getTransactions();

        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[0].fromAccount.id, fromAccount.id);
        expect(result[0].toCategory!.id, toCategory.id);
        expect(result[0].amount, 5.0);
        expect(result[0].type, TransactionType.expense);

        expect(result[1].id, 2);
        expect(result[1].fromAccount.id, fromAccount.id);
        expect(result[1].toAccount!.id, toAccount.id);
        expect(result[1].amount, 200.0);
        expect(result[1].type, TransactionType.transfer);

        verify(mockDatabase.query('transactions')).called(1);
        verify(mockAccountsRepositories.getAllAccounts()).called(1);
        verify(mockCategoriesRepositories.getAllCategories()).called(1);
        verify(mockCurrencyRepositories.getMainCurrency()).called(1);
      });

      test('handles transactions with null to_account_id and to_category_id', () async {
        final rawTransactions = [
          {
            'id': 1,
            'from_account_id': 1,
            'to_account_id': null,
            'to_category_id': null,
            'amount': 50.0,
            'date': '2025-06-25 10:00:00',
            'type': 'something', // This should be skipped
            'note': 'Invalid transaction',
            'currency': 'sgd'
          },
          {
            'id': 2,
            'from_account_id': 1,
            'to_account_id': 2,
            'to_category_id': null,
            'amount': 200.0,
            'date': '2025-06-24 15:30:00',
            'type': 'transfer',
            'note': 'Savings transfer',
            'currency': 'sgd'
          },
        ];

        when(mockDatabase.query('transactions'))
            .thenAnswer((_) async => rawTransactions);
        when(mockAccountsRepositories.getAllAccounts())
            .thenAnswer((_) async => [fromAccount, toAccount]);
        when(mockCategoriesRepositories.getAllCategories())
            .thenAnswer((_) async => [toCategory]);
        when(mockCurrencyRepositories.getMainCurrency())
            .thenAnswer((_) async => currency);

        final result = await transactionsRepositories.getTransactions();
        expect(result.length, 1); // Only the valid transaction should be returned
        expect(result[0].id, 2);
      });
    });

    test('deleteTransactionByAccountId deletes transactions by from and to account IDs', () async {
      const accountId = 1;
      when(mockDatabase.delete('transactions',
          where: 'from_account_id = ?', whereArgs: [accountId]))
          .thenAnswer((_) async => 1);
      when(mockDatabase.delete('transactions',
          where: 'to_account_id = ?', whereArgs: [accountId]))
          .thenAnswer((_) async => 1);

      await transactionsRepositories.deleteTransactionByAccountId(accountId);

      verify(mockDatabase.delete('transactions',
          where: 'from_account_id = ?', whereArgs: [accountId]))
          .called(1);
      verify(mockDatabase.delete('transactions',
          where: 'to_account_id = ?', whereArgs: [accountId]))
          .called(1);
    });

    test('deleteTransaction deletes a transaction by ID', () async {
      const transactionId = 1;
      when(mockDatabase.delete('transactions',
          where: 'id = ?', whereArgs: [transactionId]))
          .thenAnswer((_) async => 1);

      await transactionsRepositories.deleteTransaction(transactionId);

      verify(mockDatabase.delete('transactions',
          where: 'id = ?', whereArgs: [transactionId]))
          .called(1);
    });

    test('deleteTransactionByCategoryId deletes transactions by category ID', () async {
      const categoryId = 1;
      when(mockDatabase.delete('transactions',
          where: 'to_category_id = ?', whereArgs: [categoryId]))
          .thenAnswer((_) async => 1);

      await transactionsRepositories.deleteTransactionByCategoryId(categoryId);

      verify(mockDatabase.delete('transactions',
          where: 'to_category_id = ?', whereArgs: [categoryId]))
          .called(1);
    });
  });
}
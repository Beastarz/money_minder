import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/repositories/currency_repositories.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';

import 'test.mocks.dart'; 


void main() {
  late MockDatabaseService mockDatabaseService;
  late MockDatabase mockDatabase;
  late MockAccountsRepositories mockAccountsRepositories;
  late MockCategoriesRepositories mockCategoriesRepositories;
  late MockCurrencyRepositories mockCurrencyRepositories;
  late RecurrenceRepositories recurrenceRepositories;
  late MockTransactionsRepositories mockTransactionsRepositories;

  final sgdCurrency = Currency.of('sgd');
  final Icon icon = Icon(Icons.add);
  final Color color = Colors.red;
  final String description = 'test';
  final String note = 'note';
  final DateTime date = DateTime.parse('2025-06-27');

  final sgdAccount = Account(
      id: 1,
      name: 'sgdAccount',
      balance: 1000.0,
      currency: sgdCurrency,
      icon: icon,
      color: color,
      isIncludesInTotal: true,
      isMain: true,
      description: description,
      type: AccountType.accounts,
      position: 0
  );

  final sgdAccount2 = Account(
      id: 2,
      name: 'sgdAccount2',
      balance: 1000.0,
      currency: sgdCurrency,
      icon: icon,
      color: color,
      isIncludesInTotal: true,
      isMain: false,
      description: description,
      type: AccountType.savings,
      position: 0
  );

  final expenseCategory = Category(id: 1,
      label: 'food',
      position: 0,
      icon: icon,
      color: color,
      isExpense: true);

  final incomeCategory = Category(id: 1,
      label: 'income',
      position: 0,
      icon: icon,
      color: color,
      isExpense: false);


  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDatabase = MockDatabase();
    mockAccountsRepositories = MockAccountsRepositories();
    mockCategoriesRepositories = MockCategoriesRepositories();
    mockCurrencyRepositories = MockCurrencyRepositories();
    mockTransactionsRepositories = MockTransactionsRepositories();

    when(mockDatabaseService.database).thenAnswer((_) async => mockDatabase);

    RecurrenceRepositories.setMockDbService(mockDatabaseService);

    AccountsRepositories.setTestInstance(mockAccountsRepositories);
    CategoriesRepositories.setTestInstance(mockCategoriesRepositories);
    CurrencyRepositories.setTestInstance(mockCurrencyRepositories);
    TransactionsRepositories.setTestInstance(mockTransactionsRepositories);

    recurrenceRepositories = RecurrenceRepositories.instance;
  });

  tearDown(() {
    // Reset the instances after each test to avoid interference
    RecurrenceRepositories.resetInstance();
    AccountsRepositories.resetInstance();
    CategoriesRepositories.resetInstance();
    CurrencyRepositories.resetInstance();
    TransactionsRepositories.resetInstance();
  });

  group('RecurrenceRepositories', () {
    test('createRecurrence inserts data into the database', () async {
      final recurrenceMap = Recurrence.insertAsMap(date: date,
          type: TransactionType.expense,
          fromAccountId: 1,
          toCategoryId: 1,
          amount: 100.0,
          currency: sgdCurrency,
          note: note,
          recurrenceType: RecurrenceType.daily);
    
      when(mockDatabase.insert('recurrence', recurrenceMap))
          .thenAnswer((_) async => 1);

      await recurrenceRepositories.createRecurrence(recurrenceMap);

      verify(mockDatabase.insert('recurrence', recurrenceMap)).called(1);
    });

    test('updateRecurrence updates data in the database', () async {
      final recurrence = Recurrence(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: null,
        toCategory: expenseCategory,
        amount: 50.0,
        date: DateTime.now(),
        type: TransactionType.expense,
        recurrenceType: RecurrenceType.monthly,
        note: 'Updated monthly food',
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      when(mockDatabase.update('recurrence', recurrence.toMap(),
          where: 'id = ?', whereArgs: [recurrence.id]))
          .thenAnswer((_) async => 1);

      await recurrenceRepositories.updateRecurrence(recurrence);

      verify(mockDatabase.update('recurrence', recurrence.toMap(),
          where: 'id = ?', whereArgs: [recurrence.id]))
          .called(1);
    });

    test('deleteRecurrenceByAccountId deletes recurrences by from and to account IDs', () async {
      const accountId = 1;
      when(mockDatabase.delete('recurrence',
          where: 'from_account_id = ?', whereArgs: [accountId]))
          .thenAnswer((_) async => 1);
      when(mockDatabase.delete('recurrence',
          where: 'to_account_id = ?', whereArgs: [accountId]))
          .thenAnswer((_) async => 1);

      await recurrenceRepositories.deleteRecurrenceByAccountId(accountId);

      verify(mockDatabase.delete('recurrence',
          where: 'from_account_id = ?', whereArgs: [accountId]))
          .called(1);
      verify(mockDatabase.delete('recurrence',
          where: 'to_account_id = ?', whereArgs: [accountId]))
          .called(1);
    });

    test('deleteRecurrence deletes a recurrence by ID', () async {
      const recurrenceId = 1;
      when(mockDatabase.delete('recurrence',
          where: 'id = ?', whereArgs: [recurrenceId]))
          .thenAnswer((_) async => 1);

      await recurrenceRepositories.deleteRecurrence(recurrenceId);

      verify(mockDatabase.delete('recurrence',
          where: 'id = ?', whereArgs: [recurrenceId]))
          .called(1);
    });

    group('getAndCheckRecurrences', () {
      final overdueExpenseRecurrence = Recurrence(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: null,
        toCategory: expenseCategory,
        amount: 50.0,
        date: DateTime.parse('2025-05-25'),
        type: TransactionType.expense,
        recurrenceType: RecurrenceType.daily,
        note: note,
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      final nonOverdueRecurrence = Recurrence(
        id: 2,
        fromAccount: sgdAccount,
        toAccount: null,
        toCategory: expenseCategory,
        amount: 50.0,
        date: DateTime.now().add(Duration(days: 1)),
        type: TransactionType.expense,
        recurrenceType: RecurrenceType.monthly,
        note: note,
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      setUp(() {
        when(mockAccountsRepositories.getAllAccounts())
            .thenAnswer((_) async => [sgdAccount, sgdAccount2]);
        when(mockCategoriesRepositories.getAllCategories())
            .thenAnswer((_) async => [expenseCategory, incomeCategory]);
        when(mockCurrencyRepositories.getMainCurrency())
            .thenAnswer((_) async => sgdCurrency);
      });

      test('should return all recurrences and process overdue ones', () async {
        when(mockDatabase.query('recurrence')).thenAnswer((_) async => [
          overdueExpenseRecurrence.toMap(),
          nonOverdueRecurrence.toMap(),
        ]);

        // Mock updateRecurrence for overdue items
        when(mockDatabase.update('recurrence', any,
            where: 'id = ?', whereArgs: [1]))
            .thenAnswer((_) async => 1);

        when(mockAccountsRepositories.getAccountById(sgdAccount.id))
            .thenAnswer((_) async => sgdAccount);
        when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
        when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});


        final result = await recurrenceRepositories.getAndCheckRecurrences();

        expect(result.length, 2);
        expect(result[0].isOverdue, false);
      });

      test('should delete recurrence if it becomes "None" after processing', () async {
        final onceOverdueRecurrenceMap = {
          'id': 5,
          'from_account_id': 1,
          'to_account_id': null,
          'to_category_id': 1,
          'amount': 30.0,
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), // Overdue
          'type': 'expense',
          'recurrence_type': 'none',
          'note': note,
          'currency': sgdCurrency.currency().name,
        };

        when(mockDatabase.query('recurrence'))
            .thenAnswer((_) async => [onceOverdueRecurrenceMap]);

        when(mockDatabase.delete('recurrence', where: 'id = ?', whereArgs: [5]))
            .thenAnswer((_) async => 1);

        when(mockDatabase.insert('transactions', any)).thenAnswer((_) async => 1);

        when(mockAccountsRepositories.getAccountById(sgdAccount.id))
            .thenAnswer((_) async => sgdAccount);
        when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
        when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});


        final result = await recurrenceRepositories.getAndCheckRecurrences();

        expect(result.length, 0); // Should be removed from the list

        verifyNever(mockDatabase.update(
            'recurrence', any,
            where: anyNamed('where'), whereArgs: anyNamed('whereArgs')));
      });

      test('should skip recurrences with null to_account_id and to_category_id', () async {
        final invalidRecurrenceMap = {
          'id': 6,
          'from_account_id': 1,
          'to_account_id': null,
          'to_category_id': null, // Both null - should be skipped
          'amount': 10.0,
          'date': DateTime.now().toIso8601String(),
          'type': 'expense',
          'recurrence_type': 'daily',
          'note': 'Invalid recurrence',
          'currency': sgdCurrency.currency().name,
        };

        when(mockDatabase.query('recurrence'))
            .thenAnswer((_) async => [invalidRecurrenceMap]);

        final result = await recurrenceRepositories.getAndCheckRecurrences();

        expect(result.length, 0); // Should not add invalid recurrence to the list
        verifyNever(mockDatabase.update('recurrence', any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')));
        verifyNever(mockDatabase.delete('recurrence', where: anyNamed('where'), whereArgs: anyNamed('whereArgs')));
      });
    });
  });
}
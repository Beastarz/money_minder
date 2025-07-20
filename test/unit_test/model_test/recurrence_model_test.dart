import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/models/transaction.dart';

void main() {
  final sgdCurrency = Currency.of('sgd');
  final myrCurrency = Currency.of('myr');
  final mainCurrency = sgdCurrency;
  final fromAccount = Account(id: 1, name: 'fromAcc', balance: 1000, icon: Icon(Icons.account_balance_wallet), color: Colors.grey, description: '', isMain: true, isIncludesInTotal: true, type: AccountType.accounts, currency: sgdCurrency, position: 1);
  final toAccount = Account(id: 2, name: 'toAcc', balance: 500, icon: Icon(Icons.account_balance_wallet), color: Colors.grey, description: '', isMain: false, isIncludesInTotal: true, type: AccountType.accounts, currency: sgdCurrency, position: 2);
  final toCategory = Category(id: 101, name: 'category', position: 1, icon: Icon(Icons.check_box), color: Colors.red, isExpense: true);

  group('Recurrence', () {
    // Test the stringToRecurrenceType function
    group('stringToRecurrenceType', () {
      test('should convert valid strings to RecurrenceType', () {
        expect(stringToRecurrenceType('none'), RecurrenceType.none);
        expect(stringToRecurrenceType('daily'), RecurrenceType.daily);
        expect(stringToRecurrenceType('weekly'), RecurrenceType.weekly);
        expect(stringToRecurrenceType('weekday'), RecurrenceType.weekday);
        expect(stringToRecurrenceType('weekend'), RecurrenceType.weekend);
        expect(stringToRecurrenceType('monthly'), RecurrenceType.monthly);
        expect(stringToRecurrenceType('yearly'), RecurrenceType.yearly);
      });

      test('should throw Exception for invalid string', () {
        expect(() => stringToRecurrenceType('invalid_type'), throwsException);
      });
    });

    // Test the constructor
    test('constructor should create a Recurrence instance', () {
      final recurrence = Recurrence(
        id: 1,
        date: DateTime(2023, 1, 1),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: toCategory,
        amount: 50.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Initial expense',
        recurrenceType: RecurrenceType.monthly,
      );

      expect(recurrence, isA<Recurrence>());
      expect(recurrence.id, 1);
      expect(recurrence.date, DateTime(2023, 1, 1));
      expect(recurrence.type, TransactionType.expense);
      expect(recurrence.fromAccount, fromAccount);
      expect(recurrence.toAccount, isNull);
      expect(recurrence.toCategory, toCategory);
      expect(recurrence.amount, 50.0);
      expect(recurrence.currency, sgdCurrency);
      expect(recurrence.mainCurrency, mainCurrency);
      expect(recurrence.note, 'Initial expense');
      expect(recurrence.recurrenceType, RecurrenceType.monthly);
    });

    // Test the fromMap factory constructor
    group('fromMap', () {
      test('should create Recurrence from map for expense type', () {
        final map = {
          'id': 2,
          'date': '2023-03-15T00:00:00.000',
          'type': 'expense',
          'from_account_id': 1,
          'to_category_id': 101,
          'amount': 25.50,
          'currency': 'myr',
          'note': 'Lunch',
          'recurrence_type': 'daily',
        };
        final recurrence = Recurrence.fromMap(
            map, fromAccount, null, toCategory, mainCurrency);

        expect(recurrence.id, 2);
        expect(recurrence.date, DateTime(2023, 3, 15));
        expect(recurrence.type, TransactionType.expense);
        expect(recurrence.fromAccount, fromAccount);
        expect(recurrence.toCategory, toCategory);
        expect(recurrence.amount, 25.50);
        expect(recurrence.currency, myrCurrency);
        expect(recurrence.note, 'Lunch');
        expect(recurrence.recurrenceType, RecurrenceType.daily);
      });

      test('should create Recurrence from map for transfer type', () {
        final map = {
          'id': 3,
          'date': '2023-04-01T00:00:00.000',
          'type': 'transfer',
          'from_account_id': 1,
          'to_account_id': 2,
          'amount': 100.0,
          'currency': 'sgd',
          'note': 'Savings transfer',
          'recurrence_type': 'weekly',
        };
        final recurrence = Recurrence.fromMap(
            map, fromAccount, toAccount, null, mainCurrency);

        expect(recurrence.id, 3);
        expect(recurrence.type, TransactionType.transfer);
        expect(recurrence.toAccount, toAccount);
        expect(recurrence.toCategory, isNull);
      });

      test('should create Recurrence from map for income type', () {
        final map = {
          'id': 4,
          'date': '2023-05-01T00:00:00.000',
          'type': 'income',
          'from_account_id': 1, // Income usually doesn't have from_account_id, but mocking the map.
          'to_category_id': 102,
          'amount': 1500.0,
          'currency': 'sgd',
          'note': 'Salary',
          'recurrence_type': 'monthly',
        };
        final incomeCategory = Category(id: 102, name: 'income', position: 2, icon: Icon(Icons.add), color: Colors.red, isExpense: false);
        final recurrence = Recurrence.fromMap(
            map, fromAccount, null, incomeCategory, mainCurrency);

        expect(recurrence.id, 4);
        expect(recurrence.type, TransactionType.income);
        expect(recurrence.toCategory, incomeCategory);
      });

      test(
          'fromMap should increment date if weekday recurrence falls on weekend',
              () {
            // A Saturday date
            final saturday = DateTime(2023, 6, 10); // June 10, 2023 was a Saturday
            final map = {
              'id': 5,
              'date': saturday.toIso8601String(),
              'type': 'expense',
              'from_account_id': 1,
              'to_category_id': 101,
              'amount': 10.0,
              'currency': 'sgd',
              'note': 'Coffee',
              'recurrence_type': 'weekday',
            };
            final recurrence = Recurrence.fromMap(
                map, fromAccount, null, toCategory, mainCurrency);
            // Should increment past Saturday and Sunday to Monday (June 12)
            expect(recurrence.date, DateTime(2023, 6, 12));
            expect(recurrence.date.weekday, DateTime.monday);
          });

      test('fromMap should increment date if weekend recurrence falls on weekday', () {
        // A Monday date
        final monday = DateTime(2023, 6, 12); // June 12, 2023 was a Monday
        final map = {
          'id': 6,
          'date': monday.toIso8601String(),
          'type': 'expense',
          'from_account_id': 1,
          'to_category_id': 101,
          'amount': 20.0,
          'currency': 'sgd',
          'note': 'Dinner',
          'recurrence_type': 'weekend',
        };
        final recurrence = Recurrence.fromMap(
            map, fromAccount, null, toCategory, mainCurrency);
        // Should increment past Tuesday, Wednesday, Thursday, Friday to Saturday (June 17)
        expect(recurrence.date, DateTime(2023, 6, 17));
        expect(recurrence.date.weekday, DateTime.saturday);
      });
    });

    // Test toMap method
    test('toMap should correctly convert Recurrence to map', () {
      final recurrence = Recurrence(
        id: 7,
        date: DateTime(2024, 7, 1),
        type: TransactionType.income,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: toCategory,
        amount: 200.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Side gig',
        recurrenceType: RecurrenceType.yearly,
      );

      final expectedMap = {
        'id': 7,
        'date': '2024-07-01T00:00:00.000',
        'type': 'income',
        'from_account_id': 1,
        'to_account_id': null,
        'to_category_id': 101,
        'amount': 200.0,
        'currency': 'SGD',
        'note': 'Side gig',
        'recurrence_type': 'yearly',
      };
      expect(recurrence.toMap(), expectedMap);
    });

    // Test isNone getter
    test('isNone should return true if recurrenceType is none', () {
      final recurrence = Recurrence(
        id: 8,
        date: DateTime(2023, 1, 1),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: toCategory,
        amount: 10.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: '',
        recurrenceType: RecurrenceType.none,
      );
      expect(recurrence.isNone, isTrue);
    });

    test('isNone should return false if recurrenceType is not none', () {
      final recurrence = Recurrence(
        id: 9,
        date: DateTime(2023, 1, 1),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: toCategory,
        amount: 10.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: '',
        recurrenceType: RecurrenceType.daily,
      );
      expect(recurrence.isNone, isFalse);
    });

    // Test isOverdue getter
    group('isOverdue', () {
      test('should return true for a past date', () {
        final recurrence = Recurrence(
          id: 10,
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.daily,
        );
        expect(recurrence.isOverdue, isTrue);
      });

      test('should return false for a future date', () {
        final recurrence = Recurrence(
          id: 11,
          date: DateTime.now().add(const Duration(days: 1)),
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.daily,
        );
        expect(recurrence.isOverdue, isFalse);
      });

      test('should return false for today\'s date (assuming date-only comparison in getter)', () {
        final recurrence = Recurrence(
          id: 12,
          date: DateTime.now(), // Sets the date to now (today)
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.daily,
        );
        expect(recurrence.isOverdue, isTrue);
      });
    });

    // Test toTransactionMap method
    test('toTransactionMap should convert Recurrence to Transaction map format', () {
      final recurrence = Recurrence(
        id: 13,
        date: DateTime(2023, 10, 26),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: toCategory,
        amount: 75.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Groceries weekly',
        recurrenceType: RecurrenceType.weekly,
      );

      final expectedMap = {
        'date': '2023-10-26T00:00:00.000',
        'type': 'expense',
        'from_account_id': 1,
        'to_account_id': null,
        'to_category_id': 101,
        'amount': 75.0,
        'currency': 'SGD',
        'note': 'Groceries weekly',
      };
      expect(recurrence.toTransactionMap(), expectedMap);
    });

    // Test increment method
    group('increment', () {
      test('should increment daily recurrence by one day', () {
        final recurrence = Recurrence(
          id: 14,
          date: DateTime(2025, 1, 1),
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.daily,
        );
        final nextRecurrence = recurrence.increment();
        expect(nextRecurrence.date, DateTime(2025, 1, 2));
      });

      test('should increment weekly recurrence by seven days', () {
        final recurrence = Recurrence(
          id: 15,
          date: DateTime(2023, 1, 1),
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.weekly,
        );
        final nextRecurrence = recurrence.increment();
        expect(nextRecurrence.date, DateTime(2023, 1, 8));
      });

      test('should increment weekday recurrence to next weekday', () {
        // Starting on a Friday
        final friday = DateTime(2023, 6, 9); // June 9, 2023 was a Friday
        final recurrence = Recurrence(
          id: 16,
          date: friday,
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.weekday,
        );
        final nextRecurrence = recurrence.increment();
        // Should skip Saturday and Sunday
        expect(nextRecurrence.date, DateTime(2023, 6, 12)); // Monday
      });

      test('should increment weekend recurrence to next weekend day', () {
        // Starting on a Friday
        final friday = DateTime(2023, 6, 9); // June 9, 2023 was a Friday
        final recurrence = Recurrence(
          id: 17,
          date: friday,
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.weekend,
        );
        final nextRecurrence = recurrence.increment();
        // Should skip Saturday and Sunday
        expect(nextRecurrence.date, DateTime(2023, 6, 10)); // Saturday
      });


      test('should increment monthly recurrence by one month', () {
        final recurrence = Recurrence(
          id: 18,
          date: DateTime(2023, 1, 31), // Test month end
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.monthly,
        );
        final nextRecurrence = recurrence.increment();
        expect(nextRecurrence.date, DateTime(2023, 2, 28));
      });

      test('should increment yearly recurrence by one year', () {
        final recurrence = Recurrence(
          id: 19,
          date: DateTime(2023, 1, 1),
          type: TransactionType.expense,
          fromAccount: fromAccount,
          toAccount: null,
          toCategory: toCategory,
          amount: 10.0,
          currency: sgdCurrency,
          mainCurrency: mainCurrency,
          note: '',
          recurrenceType: RecurrenceType.yearly,
        );
        final nextRecurrence = recurrence.increment();
        expect(nextRecurrence.date, DateTime(2024, 1, 1));
      });
    });

    // Test insertAsMap static method
    group('insertAsMap', () {
      test('should create correct map for insertion (expense)', () {
        final date = DateTime(2023, 11, 15);
        final map = Recurrence.insertAsMap(
          date: date,
          type: TransactionType.expense,
          fromAccountId: fromAccount.id,
          toCategoryId: toCategory.id,
          amount: 120.0,
          currency: sgdCurrency,
          note: 'Shopping',
          recurrenceType: RecurrenceType.monthly,
        );

        final expectedMap = {
          'date': '2023-11-15T00:00:00.000',
          'type': 'expense',
          'from_account_id': 1,
          'to_account_id': null,
          'to_category_id': 101,
          'amount': 120.0,
          'currency': 'SGD',
          'note': 'Shopping',
          'recurrence_type': 'monthly',
        };
        expect(map, expectedMap);
      });

      test('should create correct map for insertion (transfer)', () {
        final date = DateTime(2023, 12, 1);
        final map = Recurrence.insertAsMap(
          date: date,
          type: TransactionType.transfer,
          fromAccountId: fromAccount.id,
          toAccountId: toAccount.id,
          amount: 300.0,
          currency: sgdCurrency,
          note: 'Transfer to savings',
          recurrenceType: RecurrenceType.yearly,
        );

        final expectedMap = {
          'date': '2023-12-01T00:00:00.000',
          'type': 'transfer',
          'from_account_id': 1,
          'to_account_id': 2,
          'to_category_id': null,
          'amount': 300.0,
          'currency': 'SGD',
          'note': 'Transfer to savings',
          'recurrence_type': 'yearly',
        };
        expect(map, expectedMap);
      });

      test('should throw exception if both toAccountId and toCategoryId are null', () {
        final date = DateTime(2023, 1, 1);
        expect(
              () => Recurrence.insertAsMap(
            date: date,
            type: TransactionType.expense,
            fromAccountId: fromAccount.id,
            toAccountId: null,
            toCategoryId: null,
            amount: 10.0,
            currency: sgdCurrency,
            note: 'Invalid transaction',
            recurrenceType: RecurrenceType.daily,
          ),
          throwsA(isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains('toAccountId and toCategoryId cannot be null at the same time'),
          )),
        );
      });
    });

    // Test copyWith method
    group('copyWith', () {
      final originalRecurrence = Recurrence(
        id: 1,
        date: DateTime(2023, 1, 1),
        type: TransactionType.expense,
        fromAccount: fromAccount,
        toAccount: null,
        toCategory: toCategory,
        amount: 50.0,
        currency: sgdCurrency,
        mainCurrency: mainCurrency,
        note: 'Original note',
        recurrenceType: RecurrenceType.monthly,
      );

      test('should create a copy with no changes if no parameters are provided', () {
        final copiedRecurrence = originalRecurrence.copyWith();
        expect(copiedRecurrence.id, originalRecurrence.id);
        expect(copiedRecurrence.date, originalRecurrence.date);
        expect(copiedRecurrence.type, originalRecurrence.type);
        expect(copiedRecurrence.fromAccount, originalRecurrence.fromAccount);
        expect(copiedRecurrence.toAccount, originalRecurrence.toAccount);
        expect(copiedRecurrence.toCategory, originalRecurrence.toCategory);
        expect(copiedRecurrence.amount, originalRecurrence.amount);
        expect(copiedRecurrence.currency, originalRecurrence.currency);
        expect(copiedRecurrence.mainCurrency, originalRecurrence.mainCurrency);
        expect(copiedRecurrence.note, originalRecurrence.note);
        expect(copiedRecurrence.recurrenceType, originalRecurrence.recurrenceType);
        expect(copiedRecurrence, isNot(same(originalRecurrence))); // Ensure it's a new instance
      });

      test('should create a copy with specified fields updated', () {
        final newDate = DateTime(2023, 2, 1);
        final newAmount = 75.0;
        final newCurrency = myrCurrency;
        final newNote = 'Updated note';
        final newRecurrenceType = RecurrenceType.weekly;

        final updatedRecurrence = originalRecurrence.copyWith(
          date: newDate,
          amount: newAmount,
          currency: newCurrency,
          note: newNote,
          recurrenceType: newRecurrenceType,
        );

        expect(updatedRecurrence.id, originalRecurrence.id); // ID should remain same
        expect(updatedRecurrence.date, newDate);
        expect(updatedRecurrence.amount, newAmount);
        expect(updatedRecurrence.currency, newCurrency);
        expect(updatedRecurrence.note, newNote);
        expect(updatedRecurrence.recurrenceType, newRecurrenceType);

        // Ensure other fields remain the same
        expect(updatedRecurrence.type, originalRecurrence.type);
        expect(updatedRecurrence.mainCurrency, originalRecurrence.mainCurrency);
      });
    });
  });
}
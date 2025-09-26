import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';

void main() {
  Currency sgdCurrency = Currency.of('sgd');
  Currency myrCurrency = Currency.of('myr');

  group('Account', () {
    // Test the constructor
    test('constructor should create Account instance', () {
      final account = Account(
          id: 1,
          name: 'test',
          balance: 1000,
          icon: Icon(Icons.account_balance_wallet),
          color: Colors.red,
          description: 'for test',
          isMain: true,
          isIncludesInTotal: true,
          type: AccountType.accounts,
          currency: sgdCurrency,
          position: 1
      );

      expect(account, isA<Account>());
      expect(account.id, 1);
      expect(account.name, 'test');
      expect(account.balance, 1000);
      expect(account.icon.icon, Icons.account_balance_wallet);
      expect(account.color, Colors.red);
      expect(account.description, 'for test');
      expect(account.isMain, true);
      expect(account.isIncludesInTotal, true);
      expect(account.type, AccountType.accounts);
      expect(account.currency, sgdCurrency);
      expect(account.position, 1);
    });

    // Test the fromMap factory constructor
    group('fromMap', () {
      test('should create regular Account from map', () {
        final map = {
          'id': 2,
          'name': 'test2',
          'balance': 2000.00,
          'icon': 0xe850,
          'color': 0xFF4CAF50,
          'description': 'for test2',
          'is_main': 0,
          'includes_in_total': 1,
          'type': 'accounts',
          'currency': 'sgd',
          'position': 2
        };

        final account = Account.fromMap(map);

        expect(account, isA<Account>());
        expect(account.id, 2);
        expect(account.name, 'test2');
        expect(account.balance, 2000);
        expect(account.icon.icon, IconData(0xe850, fontFamily: 'MaterialSymbolsOutlined'));
        expect(account.color, Color(0xFF4CAF50));
        expect(account.description, 'for test2');
        expect(account.isMain, false);
        expect(account.isIncludesInTotal, true);
        expect(account.type, AccountType.accounts);
        expect(account.currency, sgdCurrency);
        expect(account.position, 2);
      });

      test('should create debts Account from map', () {
        final map = {
          'id': 2,
          'name': 'test2',
          'balance': 2000.00,
          'icon': 0xe850,
          'color': 0xFF4CAF50,
          'description': 'for test2',
          'is_main': 0,
          'includes_in_total': 1,
          'type': 'debts',
          'currency': 'sgd',
          'position': 2
        };

        final account = Account.fromMap(map);

        expect(account.type, AccountType.debts);
      });

      test('should create savings Account from map', () {
        final map = {
          'id': 2,
          'name': 'test2',
          'balance': 2000.00,
          'icon': 0xe850,
          'color': 0xFF4CAF50,
          'description': 'for test2',
          'is_main': 0,
          'includes_in_total': 1,
          'type': 'savings',
          'currency': 'sgd',
          'position': 2
        };

        final account = Account.fromMap(map);

        expect(account.type, AccountType.savings);
      });

      test('should create Account with myr currency from map', () {
        final map = {
          'id': 2,
          'name': 'test2',
          'balance': 2000.00,
          'icon': 0xe850,
          'color': 0xFF4CAF50,
          'description': 'for test2',
          'is_main': 0,
          'includes_in_total': 1,
          'type': 'accounts',
          'currency': 'myr',
          'position': 2
        };

        final account = Account.fromMap(map);

        expect(account.currency, myrCurrency);
      });
    });

    group('toMap', () {
      test('should create map from Account', () {
        final map = {
          'id': 3,
          'name': 'test3',
          'balance': 2000.00,
          'icon': 0xe850,
          'color': 0xFF4CAF50,
          'description': 'for test3',
          'is_main': 0,
          'includes_in_total': 1,
          'type': 'accounts',
          'currency': 'SGD',
          'position': 2
        };

        Account account = Account(id: 3,
            name: 'test3',
            balance: 2000,
            icon: Icon(IconData(0xe850, fontFamily: 'MaterialSymbolsOutlined')),
            color: Color(0xFF4CAF50),
            description: 'for test3',
            isMain: false,
            isIncludesInTotal: true,
            type: AccountType.accounts,
            currency: sgdCurrency,
            position: 2
        );

        expect(account.toMap(), map);
      });
    });

    group('insertAsMap', () {
      test('should create correct map for insertion', () {
        Map<String, dynamic> map = {
          'name': 'test4',
          'balance': 2000.00,
          'icon': 0xe850,
          'color': 0xFF4CAF50,
          'description': 'for test4',
          'is_main': 0,
          'includes_in_total': 1,
          'type': 'debts',
          'currency': 'MYR',
        };

        Map<String, dynamic> result = Account.insertAsMap(
            name: 'test4',
            balance: 2000,
            icon: Icon(IconData(0xe850, fontFamily: 'MaterialSymbolsOutlined')),
            color: Color(0xFF4CAF50),
            description: 'for test4',
            isIncludesInTotal: true,
            type: AccountType.debts,
            currency: myrCurrency,
        );
        expect(result, map);
      });
    });

    group('calculateBalance', () {
      Account account1 = Account(id: 1,
          name: 'test1',
          balance: 2000,
          icon: Icon(IconData(0xe850, fontFamily: 'MaterialSymbolsOutlined')),
          color: Color(0xFF4CAF50),
          description: 'for test',
          isMain: false,
          isIncludesInTotal: true,
          type: AccountType.accounts,
          currency: sgdCurrency,
          position: 1
      );

      Account account2 = Account(id: 2,
          name: 'test2',
          balance: 1000,
          icon: Icon(IconData(0xe850, fontFamily: 'MaterialSymbolsOutlined')),
          color: Color(0xFF4CAF50),
          description: 'for test',
          isMain: false,
          isIncludesInTotal: true,
          type: AccountType.accounts,
          currency: sgdCurrency,
          position: 2
      );

      Account account3 = Account(id: 3,
          name: 'test4',
          balance: 3300,
          icon: Icon(IconData(0xe850, fontFamily: 'MaterialSymbolsOutlined')),
          color: Color(0xFF4CAF50),
          description: 'for test4',
          isIncludesInTotal: true,
          type: AccountType.debts,
          currency: myrCurrency,
          isMain: false,
          position: 3
      );

      test('should return the correct total balance of accounts with same currency', () {
        expect(Account.calculateBalance([account1, account2], sgdCurrency), closeTo(3000, 5));
      });

      test('should return the correct total balance of accounts with different currency', () {
        expect(Account.calculateBalance([account1, account2, account3], sgdCurrency), closeTo(4000, 5));
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        Account account1 = Account(id: 1,
            name: 'test1',
            balance: 2000,
            icon: Icon(IconData(0xe850, fontFamily: 'MaterialSymbolsOutlined')),
            color: Color(0xFF4CAF50),
            description: 'for test',
            isMain: false,
            isIncludesInTotal: true,
            type: AccountType.accounts,
            currency: sgdCurrency,
            position: 1
        );

        Account account2 = account1.copyWith(
          name: 'test2',
          balance: 1000,
          description: 'test copy',
          isMain: true,
          isIncludesInTotal: false,
          type: AccountType.debts,
          currency: myrCurrency,
        );

        expect(account2.id, account1.id);
        expect(account2.name, 'test2');
        expect(account2.balance, 1000);
        expect(account2.icon.icon, account1.icon.icon);
        expect(account2.color, account1.color);
        expect(account2.description, 'test copy');
        expect(account2.isMain, true);
        expect(account2.isIncludesInTotal, false);
        expect(account2.type, AccountType.debts);
        expect(account2.currency, myrCurrency);
        expect(account2.position, account1.position);
      });
    });
  });
}
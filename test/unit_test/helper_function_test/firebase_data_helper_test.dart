import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/components/manage_data/firebase_data_helper.dart';

void main() {
  group('FirebaseDataHelper', () {
    final mockAccountData = [
      {
        'id': 1,
        'name': 'Cash Wallet',
        'balance': 100.0,
        'icon': Icons.wallet.codePoint,
        'color': Colors.green.toARGB32(),
        'description': 'Physical cash',
        'isMain': true,
        'isIncludesInTotal': true,
        'type': 'accounts',
        'currency': 'MYR',
        'position': 0,
      },
      {
        'id': 2,
        'name': 'Bank',
        'balance': 5000.0,
        'icon': Icons.account_balance.codePoint,
        'color': Colors.blue.toARGB32(),
        'description': 'Maybank',
        'isMain': false,
        'isIncludesInTotal': true,
        'type': 'savings',
        'currency': 'SGD',
        'position': 1,
      },
    ];

    final mockCategoryData = [
      {
        'id': 10,
        'name': 'Food',
        'position': 0,
        'icon': Icons.fastfood.codePoint,
        'color': Colors.red.toARGB32(),
        'isExpense': true,
      },
      {
        'id': 11,
        'name': 'Salary',
        'position': 1,
        'icon': Icons.attach_money.codePoint,
        'color': Colors.green.toARGB32(),
        'isExpense': false,
      },
    ];

    test('idToAccount maps IDs to account names correctly', () {
      final result = FirebaseDataHelper.idToAccount(mockAccountData);
      expect(result, {
        1: 'Cash Wallet',
        2: 'Bank',
      });
    });

    test('idToCategory maps IDs to category names correctly', () {
      final result = FirebaseDataHelper.idToCategory(mockCategoryData);
      expect(result, {
        10: 'Food',
        11: 'Salary',
      });
    });

    test('accountToId maps account names to IDs correctly', () {
      final result = FirebaseDataHelper.accountToId(mockAccountData);
      expect(result, {
        'Cash Wallet': 1,
        'Bank': 2,
      });
    });

    test('categoryToId maps category names to IDs correctly', () {
      final result = FirebaseDataHelper.categoryToId(mockCategoryData);
      expect(result, {
        'Food': 10,
        'Salary': 11,
      });
    });
  });
}

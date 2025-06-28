import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/currency.dart';

import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';

import 'test.mocks.dart';

void main() {
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;
  late MockBatch mockBatch; // For batch operations
  late MockTransactionsRepositories mockTransactionsRepo;
  late MockRecurrenceRepositories mockRecurrenceRepo;
  late AccountsRepositories accountsRepository;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();
    mockBatch = MockBatch();
    mockTransactionsRepo = MockTransactionsRepositories();
    mockRecurrenceRepo = MockRecurrenceRepositories();

    // Configure the mock DatabaseService to return the mock Database instance
    // whenever its `database` getter is called.
    when(mockDbService.database).thenAnswer((_) async => mockDatabase);

    AccountsRepositories.setMockDbService(mockDbService);

    TransactionsRepositories.setTestInstance(mockTransactionsRepo);
    RecurrenceRepositories.setTestInstance(mockRecurrenceRepo);

    accountsRepository = AccountsRepositories.instance;
  });

  tearDown(() {
    reset(mockDbService);
    reset(mockDatabase);
    reset(mockBatch);
    reset(mockTransactionsRepo);
    reset(mockRecurrenceRepo);

    AccountsRepositories.resetInstance();
    TransactionsRepositories.resetInstance();
    RecurrenceRepositories.resetInstance();
  });

  group('AccountsRepository Tests', () {
    test('createAccount should insert a new account with correct position', () async {
      when(mockDatabase.rawQuery('SELECT COUNT(*) FROM accounts'))
          .thenAnswer((_) async => [{'COUNT(*)': 0}]);
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      final accountData = Account.insertAsMap(name: 'Cash Account',
          balance: 2000,
          icon: Icon(Icons.add),
          color: Colors.black54,
          description: 'des',
          isIncludesInTotal: true,
          type: AccountType.accounts,
          currency: Currency.of('sgd'));

      await accountsRepository.createAccount(accountData);

      // Capture the argument passed to insert to check its content, especially 'position'
      final capturedArgs = verify(mockDatabase.insert('accounts', captureAny)).captured.first as Map<String, dynamic>;
      expect(capturedArgs['position'], 0); // Expect position to be 0 for the first account
      expect(capturedArgs['name'], 'Cash Account');
    });

    test('getAllAccounts should return a list of Account objects', () async {
      final mockAccountsData = [
        {'id': 1, 'name': 'Cash', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': 100.0, 'description': 'test', 'currency': 'sgd', 'position': 0, 'is_main': 1, 'is_includes_in_total': 1},
        {'id': 2, 'name': 'Bank', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': 500.0, 'description': 'test', 'currency': 'myr', 'position': 1, 'is_main': 0, 'is_includes_in_total': 1},
      ];

      when(mockDatabase.query('accounts', orderBy: 'position ASC'))
          .thenAnswer((_) async => mockAccountsData);

      final accounts = await accountsRepository.getAllAccounts();

      expect(accounts, isA<List<Account>>());
      expect(accounts.length, 2);
      expect(accounts[0].name, 'Cash');
      expect(accounts[1].balance, 500.0);
      expect(accounts[0].isMain, true);

      verify(mockDatabase.query('accounts', orderBy: 'position ASC')).called(1);
    });

    test('getAccountById should return a single Account', () async {
      final mockAccountData = [
        {'id': 1, 'name': 'Test Account', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': 200.0, 'description': 'test', 'currency': 'sgd', 'position': 0, 'is_main': 1, 'is_includes_in_total': 1},
      ];
      when(mockDatabase.query('accounts', where: 'id = ?', whereArgs: [1]))
          .thenAnswer((_) async => mockAccountData);

      final account = await accountsRepository.getAccountById(1);

      expect(account.id, 1);
      expect(account.name, 'Test Account');
      verify(mockDatabase.query('accounts', where: 'id = ?', whereArgs: [1])).called(1);
    });

    test('getMainAccounts should return the main account', () async {
      final mockMainAccountData = [
        {'id': 1, 'name': 'Main Account', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': 200.0, 'description': 'test', 'currency': 'sgd', 'position': 0, 'is_main': 1, 'is_includes_in_total': 1},
      ];
      when(mockDatabase.query('accounts', where: 'is_main = 1', orderBy: 'position ASC'))
          .thenAnswer((_) async => mockMainAccountData);

      final mainAccount = await accountsRepository.getMainAccounts();

      expect(mainAccount.name, 'Main Account');
      expect(mainAccount.id, 1);
      expect(mainAccount.isMain, true);
      verify(mockDatabase.query('accounts', where: 'is_main = 1', orderBy: 'position ASC')).called(1);
    });

    test('updateAccount should update an existing account', () async {
      final accountToUpdate = Account(
        id: 1,
        name: 'Updated Cash',
        balance: 600.0,
        currency: Currency.of('sgd'),
        position: 0,
        isMain: true,
        isIncludesInTotal: true,
        icon: Icon(Icons.add),
        color: Colors.red,
        description: '',
        type: AccountType.accounts,
      );

      when(mockDatabase.update('accounts', accountToUpdate.toMap(), where: 'id = ?', whereArgs: [1]))
          .thenAnswer((_) async => 1);

      await accountsRepository.updateAccount(accountToUpdate);

      verify(mockDatabase.update('accounts', accountToUpdate.toMap(), where: 'id = ?', whereArgs: [1])).called(1);
    });

    test('updateSelectedAccount should update isIncludesInTotal for selected accounts', () async {
      final mockAccountsData = [
        {'id': 1, 'name': 'Cash', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': 100.0, 'description': 'test', 'currency': 'sgd', 'position': 0, 'is_main': 1, 'is_includes_in_total': 1},
        {'id': 2, 'name': 'Bank', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': 100.0, 'description': 'test', 'currency': 'sgd', 'position': 1, 'is_main': 0, 'is_includes_in_total': 1},
        {'id': 3, 'name': 'Credit Card', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': -100.0, 'description': 'test', 'currency': 'sgd', 'position': 2, 'is_main': 0, 'is_includes_in_total': 0},
      ];

      when(mockDatabase.query('accounts', orderBy: 'position ASC'))
          .thenAnswer((_) async => mockAccountsData);

      when(mockDatabase.batch()).thenReturn(mockBatch);
      when(mockBatch.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => 1); // Simulate successful update for each batch item
      when(mockBatch.commit()).thenAnswer((_) async => [1, 1, 1]); // Simulate successful commit

      final selectedAccountIds = [1, 3]; // Account 1 and 3 should be included

      await accountsRepository.updateIncludedAccount(selectedAccountIds);

      verify(mockDatabase.query('accounts', orderBy: 'position ASC')).called(1);
      verify(mockDatabase.batch()).called(1);

      // Account 1: was true, remains true
      verify(mockBatch.update('accounts', any, where: 'id = ?', whereArgs: [1])).called(1);

      // Account 2: was true, should become false
      verify(mockBatch.update('accounts', any, where: 'id = ?', whereArgs: [2])).called(1);

      // Account 3: was false, should become true
      verify(mockBatch.update('accounts', any, where: 'id = ?', whereArgs: [3])).called(1);

      verify(mockBatch.commit()).called(1);
    });


    test('updateAccountPosition should update positions in a batch', () async {
      final accountsToReorder = [
        Account(
          id: 2,
          name: 'Cash',
          balance: 600.0,
          currency: Currency.of('sgd'),
          position: 0,
          isMain: true,
          isIncludesInTotal: true,
          icon: Icon(Icons.add),
          color: Colors.red,
          description: '',
          type: AccountType.accounts,
        ),
        Account(
          id: 1,
          name: 'Bank',
          balance: 600.0,
          currency: Currency.of('sgd'),
          position: 1,
          isMain: false,
          isIncludesInTotal: true,
          icon: Icon(Icons.add),
          color: Colors.red,
          description: '',
          type: AccountType.accounts,
        )
      ];

      when(mockDatabase.batch()).thenReturn(mockBatch);
      when(mockBatch.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => 1);
      when(mockBatch.commit()).thenAnswer((_) async => [1, 1]);

      await accountsRepository.updateAccountPosition(accountsToReorder);

      verify(mockDatabase.batch()).called(1);

      verify(mockBatch.update('accounts', argThat(
          containsPair('position', 0)
      ), where: 'id = ?', whereArgs: [2])).called(1);

      verify(mockBatch.update('accounts', argThat(
          containsPair('position', 1)
      ), where: 'id = ?', whereArgs: [1])).called(1);

      verify(mockBatch.commit()).called(1);
    });

    test('updateMainAccount should switch main account status', () async {
      final oldMainAccountData = [
        {'id': 1, 'name': 'Cash', 'icon': 0xe850, 'color': 0xFF4CAF50, 'balance': 100.0, 'description': 'test', 'currency': 'sgd', 'position': 0, 'is_main': 1, 'is_includes_in_total': 1},
      ];
      final newMainAccount =Account(
        id: 2,
        name: 'Bank',
        balance: 600.0,
        currency: Currency.of('sgd'),
        position: 1,
        isMain: false,
        isIncludesInTotal: true,
        icon: Icon(Icons.add),
        color: Colors.red,
        description: '',
        type: AccountType.accounts,
      );

      when(mockDatabase.query('accounts', where: 'is_main = 1'))
          .thenAnswer((_) async => oldMainAccountData);
      when(mockDatabase.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => 1);

      await accountsRepository.updateMainAccount(newMainAccount);

      verify(mockDatabase.query('accounts', where: 'is_main = 1')).called(1);

      verify(mockDatabase.update('accounts', argThat(
          containsPair('is_main', 0)
      ), where: 'id = ?', whereArgs: [1])).called(1);

      verify(mockDatabase.update('accounts', argThat(
          containsPair('is_main', 1)
      ), where: 'id = ?', whereArgs: [2])).called(1);
    });

    test('deleteAccount should delete account and associated transactions/recurrences', () async {
      const accountIdToDelete = 10;

      when(mockTransactionsRepo.deleteTransactionByAccountId(accountIdToDelete))
          .thenAnswer((_) async => Future.value());
      when(mockRecurrenceRepo.deleteRecurrenceByAccountId(accountIdToDelete))
          .thenAnswer((_) async => Future.value());
      when(mockDatabase.delete('accounts', where: 'id = ?', whereArgs: [accountIdToDelete]))
          .thenAnswer((_) async => 1); // Simulate 1 row deleted

      await accountsRepository.deleteAccount(accountIdToDelete);

      // Verify all delete methods were called
      verify(mockTransactionsRepo.deleteTransactionByAccountId(accountIdToDelete)).called(1);
      verify(mockRecurrenceRepo.deleteRecurrenceByAccountId(accountIdToDelete)).called(1);
      verify(mockDatabase.delete('accounts', where: 'id = ?', whereArgs: [accountIdToDelete])).called(1);
    });

    test('close should close the database connection', () async {
      when(mockDatabase.close()).thenAnswer((_) async => Future.value());

      await accountsRepository.close();

      verify(mockDatabase.close()).called(1);
    });
  });
}
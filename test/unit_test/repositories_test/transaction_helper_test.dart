import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/transaction_helper.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';

import 'test.mocks.dart';

void main() {
  late MockAccountsRepositories mockAccountsRepositories;
  late MockTransactionsRepositories mockTransactionsRepositories;

  // Define common test data
  final sgdCurrency = Currency.of('sgd');
  final myrCurrency = Currency.of('myr');
  final Icon icon = Icon(Icons.account_balance_wallet);
  final Color color = Colors.blue;
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
  final myrAccount = Account(
      id: 3,
      name: 'myrAccount',
      balance: 1000.0,
      currency: myrCurrency,
      icon: icon,
      color: color,
      isIncludesInTotal: true,
      isMain: false,
      description: description,
      type: AccountType.accounts,
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
    mockAccountsRepositories = MockAccountsRepositories();
    mockTransactionsRepositories = MockTransactionsRepositories();

    AccountsRepositories.setTestInstance(mockAccountsRepositories);
    TransactionsRepositories.setTestInstance(mockTransactionsRepositories);
  });

  tearDown(() {
    AccountsRepositories.resetInstance();
    TransactionsRepositories.resetInstance();
  });

  group('TransactionHelper', () {
    test('proceedExpense should decrease account balance and create transaction', () async {
      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});

      const amount = 50.0;

      await TransactionHelper.proceedExpense(
          date, sgdAccount.id, expenseCategory, amount, sgdCurrency, note);

      // Verify account balance update
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance - amount),
        ),
      )).called(1);

      // Verify transaction creation
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'expense')
              .having((map) => map['from_account_id'], 'from_account_id', sgdAccount.id)
              .having((map) => map['to_category_id'], 'to_category_id', expenseCategory.id)
              .having((map) => map['amount'], 'amount', amount),
        ),
      )).called(1);
    });

    test('proceedExpense with different currencies should convert amount', () async {
      when(mockAccountsRepositories.getAccountById(myrAccount.id))
          .thenAnswer((_) async => myrAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});

      const amount = 10.0; 
      const expectedMyrAmount = 33.0; // * 3.3

      await TransactionHelper.proceedExpense(
          date, myrAccount.id, expenseCategory, amount, sgdCurrency, note);

      // Verify account balance update with converted amount
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance,
              'balance',
              closeTo(myrAccount.balance - expectedMyrAmount, 0.001)),
        ),
      )).called(1); 

      // Verify transaction creation
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'expense')
              .having((map) => map['from_account_id'], 'from_account_id', myrAccount.id)
              .having((map) => map['to_category_id'], 'to_category_id', expenseCategory.id)
              .having((map) => map['amount'], 'amount', amount) 
              .having((map) => map['currency'], 'currency', sgdCurrency.currency().name),
        ),
      )).called(1);
    });

    test('proceedExpense should call proceedIncome if category is income', () async {

      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});

      const amount = 100.0;

      await TransactionHelper.proceedExpense(
          date, sgdAccount.id, incomeCategory, amount, sgdCurrency, note);

      // Verify that proceedExpense did NOT update balance as an expense
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having((account) => account.balance, 'balance', sgdAccount.balance + amount), 
        ),
      )).called(1);

      // Verify that createTransaction was called with income type
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'income'),
        ),
      )).called(1);
    });


    test('proceedIncome should increase account balance and create transaction', () async {
      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});

      final date = DateTime.now();
      const amount = 200.0;

      await TransactionHelper.proceedIncome(
          date, sgdAccount.id, incomeCategory, amount, sgdCurrency, note);

      // Verify account balance update
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + amount),
        ),
      )).called(1);

      // Verify transaction creation
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'income')
              .having((map) => map['from_account_id'], 'from_account_id', sgdAccount.id)
              .having((map) => map['to_category_id'], 'to_category_id', incomeCategory.id)
              .having((map) => map['amount'], 'amount', amount),
        ),
      )).called(1);
    });

    test('proceedIncome should call proceedExpense if category is expense', () async {
      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});

      const amount = 50.0;

      await TransactionHelper.proceedIncome(
          date, sgdAccount.id, expenseCategory, amount, sgdCurrency, note);

      // Verify that proceedIncome did NOT update balance as an income
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having((account) => account.balance, 'balance', sgdAccount.balance - amount), // Asserting expense behavior
        ),
      )).called(1);

      // Verify that createTransaction was called with expense type
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'expense'),
        ),
      )).called(1);
    });

    test('editExpense should undo old transaction, delete it, and proceed with new expense', () async {
      final oldTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: null,
        toCategory: expenseCategory,
        amount: 50.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        note: 'Old',
        currency: sgdCurrency, 
        mainCurrency: sgdCurrency,
      );

      // Mock undoTransaction steps
      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount); // Initial state for undo
      when(mockAccountsRepositories.updateAccount(any))
          .thenAnswer((invocation) async {
        // Capture the argument of the first update call (undo)
        final updatedAccount = invocation.positionalArguments[0] as Account;
        // Return the updated account for subsequent calls within the helper (proceedExpense)
        if (updatedAccount.id == sgdAccount.id) {
          when(mockAccountsRepositories.getAccountById(sgdAccount.id)).thenAnswer((_) async => updatedAccount);
        }
      });
      when(mockTransactionsRepositories.deleteTransaction(oldTransaction.id))
          .thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any))
          .thenAnswer((_) async => {});

      const newAmount = 75.0;
      const newNote = 'New';

      await TransactionHelper.editExpense(
          oldTransaction, date, sgdAccount.id, expenseCategory, newAmount, sgdCurrency, newNote);

      // Verify undoTransaction was called (checking account balance increased by old amount)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + oldTransaction.amount),
        ),
      )).called(1);

      // Verify old transaction was deleted
      verify(mockTransactionsRepositories.deleteTransaction(oldTransaction.id)).called(1);

      // Verify new expense was proceeded (checking account balance decreased by new amount)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + oldTransaction.amount - newAmount),
        ),
      )).called(1);

      // Verify new transaction was created
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'expense')
              .having((map) => map['amount'], 'amount', newAmount)
              .having((map) => map['to_category_id'], 'to_category_id', expenseCategory.id),
        ),
      )).called(1);
    });

    test('deleteExpense should undo transaction and delete it', () async {
      final oldTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: null,
        toCategory: expenseCategory,
        amount: 50.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        note: 'Old groceries',
        currency: sgdCurrency, 
        mainCurrency: sgdCurrency,
      );

      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.deleteTransaction(oldTransaction.id))
          .thenAnswer((_) async => {});

      await TransactionHelper.deleteExpense(oldTransaction);

      // Verify undoTransaction was called (balance increased)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + oldTransaction.amount),
        ),
      )).called(1);

      // Verify transaction was deleted
      verify(mockTransactionsRepositories.deleteTransaction(oldTransaction.id)).called(1);
    });

    test('undoTransaction should revert balance for income', () async {
      final incomeTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: null,
        toCategory: incomeCategory,
        amount: 200.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.income,
        note: 'Salary received',
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});

      await TransactionHelper.undoTransaction(incomeTransaction);

      // Verify balance decreased by transaction amount
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance - incomeTransaction.amount),
        ),
      )).called(1);
    });

    test('undoTransaction should revert balance for expense', () async {
      final expenseTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: null,
        toCategory: expenseCategory,
        amount: 50.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        note: 'Groceries',
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});

      await TransactionHelper.undoTransaction(expenseTransaction);

      // Verify balance increased by transaction amount
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + expenseTransaction.amount),
        ),
      )).called(1);
    });

    test('proceedTransfer should update both account balances and create transaction', () async {
      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.getAccountById(sgdAccount2.id))
          .thenAnswer((_) async => sgdAccount2);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});

      const amount = 100.0;

      await TransactionHelper.proceedTransfer(
          date, sgdAccount.id, sgdAccount2.id, amount, sgdCurrency, note);

      // Verify checking account balance decreased
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance - amount),
        ),
      )).called(1);

      // Verify savings account balance increased
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount2.balance + amount),
        ),
      )).called(1);

      // Verify transaction creation
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'transfer')
              .having((map) => map['from_account_id'], 'from_account_id', sgdAccount.id)
              .having((map) => map['to_account_id'], 'to_account_id', sgdAccount2.id)
              .having((map) => map['amount'], 'amount', amount),
        ),
      )).called(1);
    });

    test('proceedTransfer with different currencies should convert amounts correctly', () async {

      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.getAccountById(myrAccount.id))
          .thenAnswer((_) async => myrAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any)).thenAnswer((_) async => {});

      const amount = 50.0; // Transfer 50 USD from checking to EUR account
      final expectedMyrAmount = Currency.convert(sgdCurrency, myrCurrency, amount);

      await TransactionHelper.proceedTransfer(
          date, sgdAccount.id, myrAccount.id, amount, sgdCurrency, 'Cross-currency transfer');

      // Verify checking account balance decreased (in USD)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance - amount),
        ),
      )).called(1);

      // Verify EUR account balance increased (in EUR, with conversion)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance,
              'balance',
              closeTo(myrAccount.balance + expectedMyrAmount, 0.001)),
        ),
      )).called(1);

      // Verify transaction creation
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'transfer')
              .having((map) => map['from_account_id'], 'from_account_id', sgdAccount.id)
              .having((map) => map['to_account_id'], 'to_account_id', myrAccount.id)
              .having((map) => map['amount'], 'amount', amount)
              .having((map) => map['currency'], 'currency', sgdCurrency.currency().name),
        ),
      )).called(1);
    });

    test('updateTransfer should undo old transfer, delete it, and proceed with new transfer', () async {
      final oldTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: sgdAccount2,
        toCategory: null,
        amount: 100.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.transfer,
        note: 'Old transfer',
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      // Mock for undoTransfer part
      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.getAccountById(sgdAccount2.id))
          .thenAnswer((_) async => sgdAccount2);

      when(mockAccountsRepositories.updateAccount(any))
          .thenAnswer((Invocation invocation) async {
        final updatedAccount = invocation.positionalArguments[0] as Account;
        if (updatedAccount.id == sgdAccount.id) {
          when(mockAccountsRepositories.getAccountById(sgdAccount.id))
              .thenAnswer((_) async => updatedAccount);
        } else if (updatedAccount.id == sgdAccount2.id) {
          when(mockAccountsRepositories.getAccountById(sgdAccount2.id))
              .thenAnswer((_) async => updatedAccount);
        }
      });

      when(mockTransactionsRepositories.deleteTransaction(oldTransaction.id))
          .thenAnswer((_) async => {});
      when(mockTransactionsRepositories.createTransaction(any))
          .thenAnswer((_) async => {});

      final newDate = DateTime.parse('2025-06-30');
      const newAmount = 150.0;
      const newNote = 'Updated transfer';

      await TransactionHelper.updateTransfer(
          oldTransaction, newDate, sgdAccount.id, sgdAccount2.id, newAmount, sgdCurrency, newNote);

      // Verify undoTransfer was called (checking increased, savings decreased by old amount)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + oldTransaction.amount),
        ),
      )).called(1);

      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount2.balance - oldTransaction.amount),
        ),
      )).called(1);

      // Verify old transaction was deleted
      verify(mockTransactionsRepositories.deleteTransaction(oldTransaction.id)).called(1);

      // Verify proceedTransfer was called (checking decreased, savings increased by new amount)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + oldTransaction.amount - newAmount),
        ),
      )).called(1);

      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount2.balance - oldTransaction.amount + newAmount),
        ),
      )).called(1);

      // Verify new transaction was created
      verify(mockTransactionsRepositories.createTransaction(
        argThat(
          isA<Map<String, dynamic>>()
              .having((map) => map['type'], 'type', 'transfer')
              .having((map) => map['amount'], 'amount', newAmount),
        ),
      )).called(1);
    });

    test('undoTransfer should revert balances for transfer transaction', () async {
      final transferTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: sgdAccount2,
        toCategory: null,
        amount: 100.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.transfer,
        note: 'Funds moved',
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.getAccountById(sgdAccount2.id))
          .thenAnswer((_) async => sgdAccount2);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});

      await TransactionHelper.undoTransfer(transferTransaction);

      // Verify checking account balance increased (reverting transfer out)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + transferTransaction.amount),
        ),
      )).called(1);

      // Verify savings account balance decreased (reverting transfer in)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount2.balance - transferTransaction.amount),
        ),
      )).called(1);
    });

    test('undoTransfer should do nothing if toAccount is null or type is not transfer', () async {
      final nonTransferTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: null, // toAccount is null
        toCategory: expenseCategory,
        amount: 50.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        note: 'Expense',
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      // Ensure no interaction with repositories if the condition is met
      when(mockAccountsRepositories.getAccountById(any)).thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});

      await TransactionHelper.undoTransfer(nonTransferTransaction);

      verifyNever(mockAccountsRepositories.getAccountById(any));
      verifyNever(mockAccountsRepositories.updateAccount(any));
    });

    test('deleteTransfer should undo transfer and delete it', () async {
      final oldTransaction = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        toAccount: sgdAccount2,
        toCategory: null,
        amount: 100.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.transfer,
        note: 'Transfer to delete',
        currency: sgdCurrency,
        mainCurrency: sgdCurrency,
      );

      when(mockAccountsRepositories.getAccountById(sgdAccount.id))
          .thenAnswer((_) async => sgdAccount);
      when(mockAccountsRepositories.getAccountById(sgdAccount2.id))
          .thenAnswer((_) async => sgdAccount2);
      when(mockAccountsRepositories.updateAccount(any)).thenAnswer((_) async => {});
      when(mockTransactionsRepositories.deleteTransaction(oldTransaction.id))
          .thenAnswer((_) async => {});

      await TransactionHelper.deleteTransfer(oldTransaction);

      // Verify undoTransfer was called (balances reverted)
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount.balance + oldTransaction.amount),
        ),
      )).called(1);
      verify(mockAccountsRepositories.updateAccount(
        argThat(
          isA<Account>().having(
                  (account) => account.balance, 'balance', sgdAccount2.balance - oldTransaction.amount),
        ),
      )).called(1);

      // Verify transaction was deleted
      verify(mockTransactionsRepositories.deleteTransaction(oldTransaction.id)).called(1);
    });

    test('getEarliestStartDate should return the earliest date from a list of transactions', () async {
      final transaction1 = Transaction(
        id: 1,
        fromAccount: sgdAccount,
        amount: 50.0,
        date: DateTime(2025, 1, 1),
        type: TransactionType.expense,
        currency: sgdCurrency,
        toCategory: expenseCategory,
        toAccount: null,
        note: '',
        mainCurrency: sgdCurrency,
      );
      final transaction2 = Transaction(
        id: 2,
        fromAccount: sgdAccount,
        amount: 50.0,
        date: DateTime(2025, 12, 1),
        type: TransactionType.expense,
        currency: sgdCurrency,
        toCategory: expenseCategory,
        toAccount: null,
        note: '',
        mainCurrency: sgdCurrency,
      );
      final transaction3 = Transaction(
        id: 3,
        fromAccount: sgdAccount,
        amount: 50.0,
        date: DateTime(2025, 5, 28),
        type: TransactionType.expense,
        currency: sgdCurrency,
        toCategory: expenseCategory,
        toAccount: null,
        note: '',
        mainCurrency: sgdCurrency
      );

      final transactions = [transaction1, transaction2, transaction3];

      final earliestDate = TransactionHelper.getEarliestStartDate(transactions);

      expect(earliestDate, DateTime(2025, 1, 1));
    });
  });
}
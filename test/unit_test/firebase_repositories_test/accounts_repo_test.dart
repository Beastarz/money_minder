import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/firestore_repositories/accounts_repositories.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'firebase_mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUserCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockAccountsCollection;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDoc1;
  late MockQueryDocumentSnapshot mockDoc2;
  late MockTransaction mockTransaction;
  late MockDocumentReference mockNewDoc1;
  late MockDocumentReference mockNewDoc2;

  const testUid = 'testUid';
  final account1 = Account(
    id: 1,
    name: 'Wallet',
    balance: 100.0,
    icon: const Icon(Icons.account_balance_wallet),
    color: Colors.blue,
    description: 'Cash wallet',
    isMain: true,
    isIncludesInTotal: true,
    type: AccountType.accounts,
    currency: Currency.of('SGD'),
    position: 0,
  );

  final account2 = Account(
    id: 2,
    name: 'Bank',
    balance: 500.0,
    icon: const Icon(Icons.account_balance),
    color: Colors.green,
    description: 'Main bank account',
    isMain: false,
    isIncludesInTotal: true,
    type: AccountType.savings,
    currency: Currency.of('SGD'),
    position: 1,
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUserCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockAccountsCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDoc1 = MockQueryDocumentSnapshot();
    mockDoc2 = MockQueryDocumentSnapshot();
    mockTransaction = MockTransaction();
    mockNewDoc1 = MockDocumentReference();
    mockNewDoc2 = MockDocumentReference();

    // Set up collection and doc hierarchy: users/{uid}/accounts
    when(mockFirestore.collection('users')).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(testUid)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('accounts')).thenReturn(mockAccountsCollection);

    // Stub Transaction.set method to handle the 3-parameter call
    when(mockTransaction.set(any, any, any)).thenReturn(mockTransaction);
    when(mockTransaction.set(any, any)).thenReturn(mockTransaction) ;
  });

  tearDown(() {
    // Clean up any injected instances after each test
    FirebaseAccountsRepositories.resetInstance();
  });

  group('FirebaseAccountsRepositories', () {
    test('getAllAccounts returns list of account maps', () async {
      // Arrange
      when(mockAccountsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockDoc1.data()).thenReturn(account1.toMap());
      when(mockDoc2.data()).thenReturn(account2.toMap());

      FirebaseAccountsRepositories.injectInstance(mockFirestore);
      final repo = FirebaseAccountsRepositories.instance;

      // Act
      final accounts = await repo.getAllAccounts(testUid);

      // Assert
      expect(accounts.length, 2);
      expect(accounts[0]['name'], 'Wallet');
      expect(accounts[0]['balance'], 100.0);
      expect(accounts[1]['name'], 'Bank');
      expect(accounts[1]['balance'], 500.0);

      // Verify the correct methods were called
      verify(mockFirestore.collection('users')).called(1);
      verify(mockUserCollection.doc(testUid)).called(1);
      verify(mockUserDoc.collection('accounts')).called(1);
      verify(mockAccountsCollection.get()).called(1);
    });

    test('addAllAccounts adds documents in chunks via transaction', () async {
      // Arrange
      FirebaseAccountsRepositories.injectInstance(mockFirestore);
      final repo = FirebaseAccountsRepositories.instance;

      int callCount = 0;
      final docMocks = [mockNewDoc1, mockNewDoc2];

      when(mockAccountsCollection.doc()).thenAnswer((_) => docMocks[callCount++]);

      // Mock runTransaction behavior
      when(mockFirestore.runTransaction(
        any,
        timeout: const Duration(seconds: 30),
        maxAttempts: 5,
      )).thenAnswer((invocation) async {
        final transactionHandler = invocation.positionalArguments[0] as Future<void> Function(Transaction);
        await transactionHandler(mockTransaction);
        return null;
      });

      // Act
      await repo.addAllAccounts(testUid, [account1.toMap(), account2.toMap()]);

      // Assert
      verify(mockAccountsCollection.doc()).called(2);
      // Verify with 3 parameters since Firestore calls set(docRef, data, SetOptions?)
      verify(mockTransaction.set(mockNewDoc1, account1.toMap(), null)).called(1);
      verify(mockTransaction.set(mockNewDoc2, account2.toMap(), null)).called(1);
      verify(mockFirestore.runTransaction(
        any,
        timeout: const Duration(seconds: 30),
        maxAttempts: 5,
      )).called(1);
    });

    test('addAllAccounts adds documents in chunks via transaction - alternative approach', () async {
      // Alternative: Use @GenerateNiceMocks or stub with captureAnyNamed
      FirebaseAccountsRepositories.injectInstance(mockFirestore);
      final repo = FirebaseAccountsRepositories.instance;

      int callCount = 0;
      final docMocks = [mockNewDoc1, mockNewDoc2];

      when(mockAccountsCollection.doc()).thenAnswer((_) => docMocks[callCount++]);

      // Option 2: Use captureAnyNamed for more flexible parameter matching
      when(mockFirestore.runTransaction(
        captureAny,
        timeout: captureAnyNamed('timeout'),
        maxAttempts: captureAnyNamed('maxAttempts'),
      )).thenAnswer((invocation) async {
        final transactionHandler = invocation.positionalArguments[0] as Future<void> Function(Transaction);
        await transactionHandler(mockTransaction);
        return null;
      });

      // Act
      await repo.addAllAccounts(testUid, [account1.toMap(), account2.toMap()]);

      // Assert - More flexible verification
      verify(mockAccountsCollection.doc()).called(2);
      verify(mockTransaction.set(any, any, any)).called(2);
    });

    test('deleteAllAccounts deletes all documents in the collection', () async {
      // Arrange
      when(mockAccountsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockDoc1.reference).thenReturn(mockNewDoc1);
      when(mockDoc2.reference).thenReturn(mockNewDoc2);

      FirebaseAccountsRepositories.injectInstance(mockFirestore);
      final repo = FirebaseAccountsRepositories.instance;

      // Act
      await repo.deleteAllAccounts(testUid);

      // Assert
      verify(mockAccountsCollection.get()).called(1);
      verify(mockNewDoc1.delete()).called(1);
      verify(mockNewDoc2.delete()).called(1);
    });

    test('handles empty collection in getAllAccounts', () async {
      // Arrange
      when(mockAccountsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      FirebaseAccountsRepositories.injectInstance(mockFirestore);
      final repo = FirebaseAccountsRepositories.instance;

      // Act
      final accounts = await repo.getAllAccounts(testUid);

      // Assert
      expect(accounts, isEmpty);
    });

    test('handles error in getAllAccounts', () async {
      // Arrange
      when(mockAccountsCollection.get()).thenThrow(Exception('Firestore error'));

      FirebaseAccountsRepositories.injectInstance(mockFirestore);
      final repo = FirebaseAccountsRepositories.instance;

      // Act & Assert
      expect(
            () => repo.getAllAccounts(testUid),
        throwsA(isA<Exception>()),
      );
    });
  });
}
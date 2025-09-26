import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:money_minder/firestore_repositories/transactions_repositories.dart';
import 'firebase_mocks.mocks.dart'; // Adjust path if needed

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockTransactionsCollection;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDocSnapshot;

  const String uid = 'test_user';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockTransactionsCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocSnapshot = MockQueryDocumentSnapshot();

    FirebaseTransactionsRepositories.injectInstance(mockFirestore);

    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(uid)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('transactions')).thenReturn(mockTransactionsCollection);
  });

  test('getAllTransactions returns list of transaction maps', () async {
    when(mockTransactionsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
    when(mockDocSnapshot.data()).thenReturn({'amount': 100, 'type': 'expense'});

    final result = await FirebaseTransactionsRepositories.instance.getAllTransactions(uid);

    expect(result, isA<List<Map<String, dynamic>>>());
    expect(result.first['amount'], 100);
  });

  test('deleteAllTransactions deletes each document in collection', () async {
    final mockDoc1 = MockQueryDocumentSnapshot();
    final mockDoc2 = MockQueryDocumentSnapshot();
    final mockRef1 = MockDocumentReference();
    final mockRef2 = MockDocumentReference();

    when(mockTransactionsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

    when(mockDoc1.reference).thenReturn(mockRef1);
    when(mockDoc2.reference).thenReturn(mockRef2);

    when(mockRef1.delete()).thenAnswer((_) async => {});
    when(mockRef2.delete()).thenAnswer((_) async => {});

    await FirebaseTransactionsRepositories.instance.deleteAllTransactions(uid);

    verify(mockRef1.delete()).called(1);
    verify(mockRef2.delete()).called(1);
  });
}

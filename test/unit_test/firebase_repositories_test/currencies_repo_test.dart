import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:money_minder/firestore_repositories/currencies_repositories.dart';

import 'firebase_mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockCurrencyCollection;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDocSnapshot;

  const String uid = 'test_user';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockCurrencyCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocSnapshot = MockQueryDocumentSnapshot();

    FirebaseCurrencyRepositories.injectInstance(mockFirestore);

    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(uid)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('currency')).thenReturn(mockCurrencyCollection);
  });

  test('getMainCurrency returns list of currencies', () async {
    when(mockCurrencyCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
    when(mockDocSnapshot.data()).thenReturn({'main_currency': 'USD'});

    final result = await FirebaseCurrencyRepositories.instance.getMainCurrency(uid);

    expect(result, isA<List>());
    expect(result.first['main_currency'], 'USD');
  });


  test('deleteMainCurrency deletes all documents in currency collection', () async {
    final mockDoc1 = MockQueryDocumentSnapshot();
    final mockDoc2 = MockQueryDocumentSnapshot();
    final mockRef1 = MockDocumentReference();
    final mockRef2 = MockDocumentReference();

    when(mockCurrencyCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
    when(mockDoc1.reference).thenReturn(mockRef1);
    when(mockDoc2.reference).thenReturn(mockRef2);
    when(mockRef1.delete()).thenAnswer((_) async {});
    when(mockRef2.delete()).thenAnswer((_) async {});

    await FirebaseCurrencyRepositories.instance.deleteMainCurrency(uid);

    verify(mockRef1.delete()).called(1);
    verify(mockRef2.delete()).called(1);
  });
}

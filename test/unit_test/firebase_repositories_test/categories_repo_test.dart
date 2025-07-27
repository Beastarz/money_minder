import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:money_minder/firestore_repositories/categories_repositories.dart';

import 'firebase_mocks.mocks.dart'; // Adjust the path as needed

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockCategoriesCollection;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDocSnapshot;

  const String uid = 'test_user';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockCategoriesCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocSnapshot = MockQueryDocumentSnapshot();

    // Inject mock Firestore
    FirebaseCategoriesRepositories.injectInstance(mockFirestore);

    // Setup collection/document hierarchy
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(uid)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('categories')).thenReturn(mockCategoriesCollection);
  });

  test('getAllCategories returns list of category maps', () async {
    when(mockCategoriesCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
    when(mockDocSnapshot.data()).thenReturn({'name': 'Food', 'color': 'red'});

    final result = await FirebaseCategoriesRepositories.instance.getAllCategories(uid);

    expect(result, isA<List<Map<String, dynamic>>>());
    expect(result.first['name'], 'Food');
  });

  test('addAllCategories adds each category to Firestore', () async {
    final categories = [
      {'name': 'Food', 'color': 'red'},
      {'name': 'Transport', 'color': 'blue'},
    ];

    when(mockCategoriesCollection.add(any)).thenAnswer((_) async => MockDocumentReference());

    await FirebaseCategoriesRepositories.instance.addAllCategories(uid, categories);

    verify(mockCategoriesCollection.add(categories[0])).called(1);
    verify(mockCategoriesCollection.add(categories[1])).called(1);
  });

  test('deleteAllCategories deletes each document in collection', () async {
    final mockDoc1 = MockQueryDocumentSnapshot();
    final mockDoc2 = MockQueryDocumentSnapshot();
    final mockRef1 = MockDocumentReference();
    final mockRef2 = MockDocumentReference();

    when(mockCategoriesCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

    when(mockDoc1.reference).thenReturn(mockRef1);
    when(mockDoc2.reference).thenReturn(mockRef2);

    when(mockRef1.delete()).thenAnswer((_) async => {});
    when(mockRef2.delete()).thenAnswer((_) async => {});

    await FirebaseCategoriesRepositories.instance.deleteAllCategories(uid);

    verify(mockRef1.delete()).called(1);
    verify(mockRef2.delete()).called(1);
  });

}
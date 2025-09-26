import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:money_minder/firestore_repositories/fast_notes_repositories.dart';

import 'firebase_mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockFastNotesCollection;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDocSnapshot;

  const String uid = 'test_user';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockFastNotesCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocSnapshot = MockQueryDocumentSnapshot();

    FirebaseFastNotesRepositories.injectInstance(mockFirestore);

    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(uid)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('fastNotes')).thenReturn(mockFastNotesCollection);
  });

  test('getAllFastNotes returns list of fast note maps', () async {
    when(mockFastNotesCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
    when(mockDocSnapshot.data()).thenReturn({'title': 'Note 1', 'amount': 123});

    final result = await FirebaseFastNotesRepositories.instance.getAllFastNotes(uid);

    expect(result, isA<List<Map<String, dynamic>>>());
    expect(result.first['title'], 'Note 1');
  });

  test('addAllFastNotes adds each fast note to Firestore', () async {
    final data = [
      {'title': 'Note 1', 'amount': 100, 'category': 'Food'},
      {'title': 'Note 2', 'amount': 200, 'category': 'Transport'},
    ];

    when(mockFastNotesCollection.add(any)).thenAnswer((_) async => MockDocumentReference());

    for (final fastNote in data) {
      await mockFastNotesCollection.add(fastNote);
    }

    verify(mockFastNotesCollection.add(data[0])).called(1);
    verify(mockFastNotesCollection.add(data[1])).called(1);
  });

  test('deleteAllFastNotes deletes each document in collection', () async {
    final mockDoc1 = MockQueryDocumentSnapshot();
    final mockDoc2 = MockQueryDocumentSnapshot();
    final mockRef1 = MockDocumentReference();
    final mockRef2 = MockDocumentReference();

    when(mockFastNotesCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
    when(mockDoc1.reference).thenReturn(mockRef1);
    when(mockDoc2.reference).thenReturn(mockRef2);
    when(mockRef1.delete()).thenAnswer((_) async {});
    when(mockRef2.delete()).thenAnswer((_) async {});

    await FirebaseFastNotesRepositories.instance.deleteAllFastNotes(uid);

    verify(mockRef1.delete()).called(1);
    verify(mockRef2.delete()).called(1);
  });
}

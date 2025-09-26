import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/firestore_repositories/user_contacts_repositories.dart';
import 'package:money_minder/models/online/user_contact.dart';

import 'firebase_mocks.mocks.dart'; // Uses @GenerateNiceMocks

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockContactsCollection;
  late MockDocumentReference mockContactDoc;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDocSnapshot;

  late UserContactsRepositories repo;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockContactsCollection = MockCollectionReference();
    mockContactDoc = MockDocumentReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocSnapshot = MockQueryDocumentSnapshot();

    UserContactsRepositories.injectInstance(mockFirestore);
    repo = UserContactsRepositories.instance;
  });

  test('getUserContact returns list of UserContact', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(any)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);

    when(mockDocSnapshot.id).thenReturn('uid_abc');
    when(mockDocSnapshot.data()).thenReturn({
      'username': 'test_user',
      'phoneNumber': '12345',
      'nickname': 'testy',
      'isBlocked': false,
    });

    final result = await repo.getUserContact('someUid');

    expect(result, hasLength(1));
    expect(result.first.username, 'test_user');
  });

  test('addUserContact sets data correctly', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.doc('targetUid')).thenReturn(mockContactDoc);
    when(mockContactDoc.set(any)).thenAnswer((_) async => {});

    await repo.addUserContact('uid', 'targetUid', {'username': 'alice'});

    verify(mockContactDoc.set({'username': 'alice'})).called(1);
  });

  test('updateUserContact updates document correctly', () async {
    final userContact = UserContact.fromMap(
      'c1',
      {
        'username': 'alice',
        'phoneNumber': '1234',
        'nickname': 'ally',
        'isBlocked': false,
      }
    );

    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.doc('c1')).thenReturn(mockContactDoc);
    when(mockContactDoc.set(userContact.toMap())).thenAnswer((_) async => {});

    await repo.updateUserContact('uid', userContact);

    verify(mockContactDoc.set(userContact.toMap())).called(1);
  });

  test('blockContact updates isBlocked to true', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.where('username', isEqualTo: 'bob')).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
    when(mockDocSnapshot.reference).thenReturn(mockContactDoc);
    when(mockContactDoc.update({'isBlocked': true})).thenAnswer((_) async => {});

    await repo.blockContact('uid', 'bob');

    verify(mockContactDoc.update({'isBlocked': true})).called(1);
  });

  test('unblockContact updates isBlocked to false', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.where('username', isEqualTo: 'bob')).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
    when(mockDocSnapshot.reference).thenReturn(mockContactDoc);
    when(mockContactDoc.update({'isBlocked': false})).thenAnswer((_) async => {});

    await repo.unblockContact('uid', 'bob');

    verify(mockContactDoc.update({'isBlocked': false})).called(1);
  });

  test('deleteUserContact deletes correct document', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.doc('c1')).thenReturn(mockContactDoc);
    when(mockContactDoc.delete()).thenAnswer((_) async => {});

    await repo.deleteUserContact('uid', 'c1');

    verify(mockContactDoc.delete()).called(1);
  });

  test('getUserContactById returns correct UserContact', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.where('username', isEqualTo: 'alice')).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);

    when(mockDocSnapshot.id).thenReturn('abc');
    when(mockDocSnapshot.data()).thenReturn({
      'username': 'alice',
      'phoneNumber': '8888',
      'nickname': 'ali',
      'isBlocked': false,
    });

    final result = await repo.getUserContactById('uid', 'alice');

    expect(result, isNotNull);
    expect(result?.username, 'alice');
  });

  test('getUserContactById returns null when not found', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.where('username', isEqualTo: 'bob')).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([]);

    final result = await repo.getUserContactById('uid', 'bob');

    expect(result, isNull);
  });

  test('deleteAllContact deletes all documents', () async {
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc('uid')).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('contacts')).thenReturn(mockContactsCollection);
    when(mockContactsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
    when(mockDocSnapshot.reference).thenReturn(mockContactDoc);
    when(mockContactDoc.delete()).thenAnswer((_) async => {});

    await repo.deleteAllContact('uid');

    verify(mockContactDoc.delete()).called(1);
  });
}
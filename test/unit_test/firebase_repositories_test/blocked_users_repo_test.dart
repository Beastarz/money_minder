import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/firestore_repositories/blocked_users_repositories.dart';

import 'firebase_mocks.mocks.dart'; // Make sure you generated this with build_runner

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUserCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockBlockListCollection;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDoc1;
  late MockQueryDocumentSnapshot mockDoc2;
  late MockDocumentReference mockBlockedUserDoc;

  const testUid = 'testUid';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUserCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockBlockListCollection = MockCollectionReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDoc1 = MockQueryDocumentSnapshot();
    mockDoc2 = MockQueryDocumentSnapshot();
    mockBlockedUserDoc = MockDocumentReference();

    when(mockFirestore.collection('users')).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(testUid)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('blockList')).thenReturn(mockBlockListCollection);

    // Inject mocked instance via singleton
    BlockedUsersRepositories.injectInstance(mockFirestore);
  });

  group('BlockedUsersRepositories', () {
    test('getBlockedUsernames returns usernames from documents', () async {
      when(mockBlockListCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockDoc1['username']).thenReturn('user1');
      when(mockDoc2['username']).thenReturn('user2');

      final usernames = await BlockedUsersRepositories.instance.getBlockedUsernames(testUid);

      expect(usernames, ['user1', 'user2']);
    });

    test('addBlockedUser adds a document to blockList', () async {
      when(mockBlockListCollection.add({'username': 'user1'}))
          .thenAnswer((_) async => mockBlockedUserDoc);

      await BlockedUsersRepositories.instance.addBlockedUser(testUid, 'user1');

      verify(mockBlockListCollection.add({'username': 'user1'})).called(1);
    });

    test('deleteBlockedUser deletes document with matching username', () async {
      when(mockBlockListCollection.where('username', isEqualTo: 'user1'))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1]);
      when(mockDoc1.reference).thenReturn(mockBlockedUserDoc);

      await BlockedUsersRepositories.instance.deleteBlockedUser(testUid, 'user1');

      verify(mockBlockedUserDoc.delete()).called(1);
    });

    test('deleteAllBlockedUsers deletes all documents in blockList', () async {
      when(mockBlockListCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockDoc1.reference).thenReturn(mockBlockedUserDoc);
      when(mockDoc2.reference).thenReturn(mockBlockedUserDoc);

      await BlockedUsersRepositories.instance.deleteAllBlockedUsers(testUid);

      verify(mockBlockedUserDoc.delete()).called(2);
    });

    test('getBlockedUsernames throws on Firestore error', () async {
      when(mockBlockListCollection.get()).thenThrow(Exception('Firestore error'));

      expect(
            () => BlockedUsersRepositories.instance.getBlockedUsernames(testUid),
        throwsA(isA<Exception>()),
      );
    });
  });
}

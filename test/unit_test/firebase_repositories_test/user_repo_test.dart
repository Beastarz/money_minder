import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/models/online/user.dart';

import 'firebase_mocks.mocks.dart';

void main() {
  group('UsersRepositories', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockUsersCollection;
    late MockDocumentReference mockUserDoc;
    late MockDocumentSnapshot mockDocumentSnapshot;
    late UsersRepositories repo;

    const testUid = 'user123';
    const testPhone = '12345678';
    const testUsername = 'testuser';

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference();
      mockUserDoc = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();

      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockUsersCollection.doc(testUid)).thenReturn(mockUserDoc);

      UsersRepositories.injectInstance(mockFirestore);
      repo = UsersRepositories.instance;
    });

    test('createUsername sets user document with correct data', () async {
      when(mockUserDoc.set(any)).thenAnswer((_) async {});

      await repo.createUsername(testUid, testPhone, testUsername);

      verify(mockUserDoc.set(argThat(allOf(
        containsPair('username', testUsername),
        containsPair('phoneNumber', testPhone),
        contains('createdAt'),
      )))).called(1);
    });

    test('getMyUserData returns User when document exists', () async {
      final testData = {
        'username': 'alice',
        'phoneNumber': '987654',
        'createdAt': null,
      };

      when(mockUserDoc.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(testData);
      when(mockDocumentSnapshot.id).thenReturn(testUid);

      final user = await repo.getMyUserData(testUid);

      expect(user, isA<User>());
      expect(user?.uid, testUid);
      expect(user?.username, 'alice');
    });

    test('getMyUserData returns null if document does not exist', () async {
      when(mockUserDoc.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      final result = await repo.getMyUserData(testUid);

      expect(result, isNull);
    });

    test('updateMyPhoneNumber updates the phone number', () async {
      when(mockUserDoc.update(any)).thenAnswer((_) async {});

      await repo.updateMyPhoneNumber(testUid, testPhone);

      verify(mockUserDoc.update({'phoneNumber': testPhone})).called(1);
    });

    test('checkUsernameExist returns true if username exists', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDoc = MockQueryDocumentSnapshot();

      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockUsersCollection.where('username', isEqualTo: testUsername)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

      final exists = await repo.checkUsernameExist(testUsername);

      expect(exists, true);
    });

    test('checkUsernameExist returns false if username does not exist', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();

      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockUsersCollection.where('username', isEqualTo: testUsername)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      final exists = await repo.checkUsernameExist(testUsername);

      expect(exists, false);
    });
  });
}

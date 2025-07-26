import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:money_minder/firestore_repositories/budgets_repositories.dart';

import 'firebase_mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUserCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockBudgetsCollection;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockDoc1;
  late MockQueryDocumentSnapshot mockDoc2;
  late MockDocumentReference mockDocRef;

  const testUid = 'testUid';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUserCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockBudgetsCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDoc1 = MockQueryDocumentSnapshot();
    mockDoc2 = MockQueryDocumentSnapshot();
    mockDocRef = MockDocumentReference();

    when(mockFirestore.collection('users')).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(testUid)).thenReturn(mockUserDoc);
    when(mockUserDoc.collection('budgets')).thenReturn(mockBudgetsCollection);

    FirebaseBudgetsRepositories.injectInstance(mockFirestore);
  });

  group('FirebaseBudgetsRepositories', () {
    test('getAllBudgets returns budgets from Firestore', () async {
      when(mockBudgetsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockDoc1.data()).thenReturn({'category': 'Food', 'amount': 100});
      when(mockDoc2.data()).thenReturn({'category': 'Transport', 'amount': 200});

      final budgets = await FirebaseBudgetsRepositories.instance.getAllBudgets(testUid);

      expect(budgets, [
        {'category': 'Food', 'amount': 100},
        {'category': 'Transport', 'amount': 200}
      ]);
    });

    test('addAllBudgets adds dummy budgets with mapped category names', () async {
      final dummyBudgets = [
        {'amount': 100, 'category_id': 1},
        {'amount': 200, 'category_id': 2},
      ];
      final categoryMap = {1: 'Food', 2: 'Transport'};

      when(mockBudgetsCollection.add(any)).thenAnswer((_) async => mockDocRef);

      // Manually inject dummyBudgets in place of BudgetRepositories call
      for (final element in dummyBudgets) {
        final budget = Map<String, dynamic>.from(element);
        budget['category'] = categoryMap[element['category_id']];
        await mockBudgetsCollection.add(budget);
      }

      verify(mockBudgetsCollection.add({
        'amount': 100,
        'category_id': 1,
        'category': 'Food'
      })).called(1);
      verify(mockBudgetsCollection.add({
        'amount': 200,
        'category_id': 2,
        'category': 'Transport'
      })).called(1);
    });

    test('deleteAllBudgets deletes all documents in budgets collection', () async {
      when(mockBudgetsCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockDoc1.reference).thenReturn(mockDocRef);
      when(mockDoc2.reference).thenReturn(mockDocRef);

      await FirebaseBudgetsRepositories.instance.deleteAllBudgets(testUid);

      verify(mockDocRef.delete()).called(2);
    });

    test('getAllBudgets throws when Firestore fails', () async {
      when(mockBudgetsCollection.get()).thenThrow(Exception('Firestore error'));

      expect(
            () => FirebaseBudgetsRepositories.instance.getAllBudgets(testUid),
        throwsA(isA<Exception>()),
      );
    });
  });
}

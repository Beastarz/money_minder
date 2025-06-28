import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/fast_note.dart';
import 'package:money_minder/repositories/fast_note_repositories.dart';

import 'test.mocks.dart';


void main() {
  late FastNoteRepositories fastNoteRepositories;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDatabase = MockDatabase();

    when(mockDbService.database).thenAnswer((_) async => mockDatabase);

    FastNoteRepositories.setMockDbService(mockDbService);
    fastNoteRepositories = FastNoteRepositories.instance;
  });

  tearDown(() {
    FastNoteRepositories.resetInstance();
  });

  group('FastNoteRepositories', () {
    final int codePoint = Icons.add.codePoint;
    test('createFastNote inserts a new fast note', () async {
      final newFastNoteMap = FastNote.insertAsMap(note: '', codePoint: 123, categoryId: 1);

      when(mockDatabase.insert('fast_notes', newFastNoteMap))
          .thenAnswer((_) async => 1);

      await fastNoteRepositories.createFastNote(newFastNoteMap);

      verify(mockDatabase.insert('fast_notes', newFastNoteMap)).called(1);
    });

    test('getFastNotes returns a list of FastNote for a given category', () async {
      const categoryId = 1;
      final mockData = [
        {
          'id': 1,
          'note': 'Note 1',
          'icon': codePoint,
          'category_id': 1,
        },
        {
          'id': 2,
          'note': 'Note 2',
          'icon': codePoint,
          'category_id': 1,
        },
      ];

      when(mockDatabase.query(
        'fast_notes',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      )).thenAnswer((_) async => mockData);

      final result = await fastNoteRepositories.getFastNotes(categoryId);

      expect(result, isA<List<FastNote>>());
      expect(result.length, 2);
      expect(result[0].note, 'Note 1');
      expect(result[1].categoryId, 1);
      verify(mockDatabase.query('fast_notes', where: 'category_id = ?', whereArgs: [categoryId])).called(1);
    });

    test('getFastNotes returns an empty list if no notes found for category', () async {
      const categoryId = 99;

      when(mockDatabase.query(
        'fast_notes',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      )).thenAnswer((_) async => []); // Empty list for no results

      final result = await fastNoteRepositories.getFastNotes(categoryId);

      expect(result, isA<List<FastNote>>());
      expect(result, isEmpty);
      verify(mockDatabase.query('fast_notes', where: 'category_id = ?', whereArgs: [categoryId])).called(1);
    });

    test('updateFastNote updates an existing fast note', () async {
      const fastNoteId = 1;
      const categoryId = 1;
      final updatedFastNoteMap = {
        'id': 1,
        'note': 'Updated Note',
        'icon': codePoint,
        'category_id': 1,
      };

      when(mockDatabase.update(
        'fast_notes',
        updatedFastNoteMap,
        where: 'id = ? AND category_id = ?',
        whereArgs: [fastNoteId, categoryId],
      )).thenAnswer((_) async => 1); // Simulate successful update

      await fastNoteRepositories.updateFastNote(updatedFastNoteMap, fastNoteId, categoryId);

      verify(mockDatabase.update(
        'fast_notes',
        updatedFastNoteMap,
        where: 'id = ? AND category_id = ?',
        whereArgs: [fastNoteId, categoryId],
      )).called(1);
    });

    test('deleteFastNote deletes a fast note by id and categoryId', () async {
      const fastNoteIdToDelete = 1;
      const categoryIdToDelete = 1;

      when(mockDatabase.delete(
        'fast_notes',
        where: 'id = ? AND category_id = ?',
        whereArgs: [fastNoteIdToDelete, categoryIdToDelete],
      )).thenAnswer((_) async => 1); // Simulate successful deletion

      await fastNoteRepositories.deleteFastNote(fastNoteIdToDelete, categoryIdToDelete);

      verify(mockDatabase.delete(
        'fast_notes',
        where: 'id = ? AND category_id = ?',
        whereArgs: [fastNoteIdToDelete, categoryIdToDelete],
      )).called(1);
    });
  });
}
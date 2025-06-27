import 'package:flutter/cupertino.dart';

import '../db/database.dart';
import '../models/fast_note.dart';

class FastNoteRepositories {

  DatabaseService _dbService = DatabaseService.instance;

  FastNoteRepositories._privateConstructor();

  static final FastNoteRepositories _instance = FastNoteRepositories._privateConstructor();


  static FastNoteRepositories get instance => _instance;

  @visibleForTesting
  static void setMockDbService(DatabaseService mockService) {
    _instance._dbService = mockService;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance._dbService = DatabaseService.instance;
  }

  /// create a new Fast Note
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> fastNote: data for the new Fast Note
  ///
  /// Returns: void
  Future<void> createFastNote(Map<String, dynamic> fastNote) async {
    final db = await _dbService.database;
    await db.insert(
        'fast_notes',
        fastNote);
  }


  /// get all Fast Notes of a category
  ///
  /// Parameters:
  ///
  /// int categoryId: id of the category
  ///
  /// Returns: List\<FastNote\>
  Future<List<FastNote>> getFastNotes(int categoryId) async {
    final db = await _dbService.database;
    List<Map<String, dynamic>> result = await db.query(
        'fast_notes',
        where: 'category_id = ?',
        whereArgs: [categoryId]);
    return result.map((row) => FastNote.fromMap(row)).toList();
  }


  /// update a Fast Note
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> fastNote: data for the new Fast Note
  ///
  /// Returns: void
  Future<void> updateFastNote(Map<String, dynamic> fastNote, int id, int categoryId) async {
    final db = await _dbService.database;
    await db.update(
        'fast_notes',
        fastNote,
        where: 'id = ? AND category_id = ?',
        whereArgs: [id, categoryId]);
  }

  /// delete a Fast Note
  ///
  /// Parameters:
  ///
  /// int id: id of the Fast Note
  ///
  /// Returns: void
  Future<void> deleteFastNote(int id, int categoryId) async {
    final db = await _dbService.database;
    await db.delete(
        'fast_notes',
        where: 'id = ? AND category_id = ?',
        whereArgs: [id, categoryId]);
  }
}
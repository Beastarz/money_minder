import 'package:money_minder/db/database.dart';

import '../models/passcode.dart';

class PasscodeRepositories {
  PasscodeRepositories._();
  static final PasscodeRepositories instance = PasscodeRepositories._();

  DatabaseService dbService = DatabaseService.instance;

  /// get the passcode from the database
  ///
  /// Returns: List\<Passcode\>
  Future<List<Passcode>> getPasscode() async {
    final db = await dbService.database;

    final res = await db.query('passcode');
    return res.map((map) => Passcode.fromMap(map)).toList();
  }

  /// add the passcode to the database
  ///
  /// Parameters:
  ///
  /// Map<\String, dynamic\> map: the passcode
  ///
  /// Returns: void
  Future<void> addPasscode(Map<String, dynamic> map) async {
    final db = await dbService.database;
    await db.insert('passcode', map);
  }

  /// get the active period from the database
  ///
  /// Returns: int
  Future<int> getActivePeriod() async {
    final db = await dbService.database;
    final res = await db.query('passcode');
    return res[0]['active_period'] as int;
  }

  /// update the active period in the database
  ///
  /// Parameters:
  ///
  /// int activePeriod: the new active period
  ///
  /// Returns: void
  Future<void> updateActivePeriod(int activePeriod) async {
    final db = await dbService.database;
    await db.update('passcode', {'active_period': activePeriod});
  }

  /// delete the passcode from the database
  ///
  /// Returns: void
  Future<void> deletePasscode() async {
    final db = await dbService.database;
    await db.delete('passcode');
  }
}
import 'package:money_minder/db/database.dart';

import '../models/passcode.dart';

class PasscodeRepositories {
  PasscodeRepositories._();
  static final PasscodeRepositories instance = PasscodeRepositories._();

  DatabaseService dbService = DatabaseService.instance;

  Future<List<Passcode>> getPasscode() async {
    final db = await dbService.database;

    final res = await db.query('passcode');
    return res.map((map) => Passcode.fromMap(map)).toList();
  }

  Future<void> addPasscode(Map<String, dynamic> map) async {
    final db = await dbService.database;
    await db.insert('passcode', map);
  }

  Future<int> getActivePeriod() async {
    final db = await dbService.database;
    final res = await db.query('passcode');
    return res[0]['active_period'] as int;
  }

  Future<void> updateActivePeriod(int activePeriod) async {
    final db = await dbService.database;
    await db.update('passcode', {'active_period': activePeriod});
  }

  Future<void> deletePasscode() async {
    final db = await dbService.database;
    await db.delete('passcode');
  }
}
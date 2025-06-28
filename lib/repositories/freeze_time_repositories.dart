import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/freeze_time.dart';

class FreezeTimeRepositories {
  FreezeTimeRepositories._();
  static final FreezeTimeRepositories instance = FreezeTimeRepositories._();

  DatabaseService dbService = DatabaseService.instance;

  Future<List<FreezeTime>> getFreezeTime() async {
    final db = await dbService.database;

    final res = await db.query('freeze_time');
    return res.map((map) => FreezeTime.fromMap(map)).toList();
  }

  Future<void> addFreezeTime(Map<String, dynamic> map) async {
    final db = await dbService.database;
    await db.insert('freeze_time', map);
  }

  Future<void> deleteFreezeTime() async {
    final db = await dbService.database;
    await db.delete('freeze_time');
  }
}
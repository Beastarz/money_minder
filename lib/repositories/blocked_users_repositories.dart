import 'package:flutter/cupertino.dart';
import 'package:money_minder/db/database.dart';

class BlockedUsersRepositories {
  DatabaseService _dbService = DatabaseService.instance;

  BlockedUsersRepositories._privateConstructor();

  static final BlockedUsersRepositories _instance = BlockedUsersRepositories._privateConstructor();


  static BlockedUsersRepositories get instance => _instance;

  @visibleForTesting
  static void setMockDbService(DatabaseService mockService) {
    _instance._dbService = mockService;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance._dbService = DatabaseService.instance;
  }

  Future<List<String>> getBlockedUsernames() async {
    final db = await _dbService.database;

    final res = await db.query('blocked_users');
    return res.map((map) => map['username'] as String).toList();
  }

  Future<void> addBlockedUser(String username) async {
    final db = await _dbService.database;
    await db.insert('blocked_users', {'username': username});
  }

  Future<void> deleteBlockedUser(String username) async {
    final db = await _dbService.database;
    await db.delete('blocked_users', where: 'username = ?', whereArgs: [username]);
  }
}
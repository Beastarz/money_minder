import 'package:flutter/cupertino.dart';
import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/user_contact.dart';

class UserContactsRepositories {
  DatabaseService _dbService = DatabaseService.instance;

  UserContactsRepositories._privateConstructor();

  static final UserContactsRepositories _instance = UserContactsRepositories._privateConstructor();


  static UserContactsRepositories get instance => _instance;

  @visibleForTesting
  static void setMockDbService(DatabaseService mockService) {
    _instance._dbService = mockService;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance._dbService = DatabaseService.instance;
  }

  Future<List<UserContact>> getUserContact() async {
    final db = await _dbService.database;

    final res = await db.query('user_contacts');
    return res.map((map) => UserContact.fromMap(map)).toList();
  }

  Future<void> addUserContact(Map<String, dynamic> map) async {
    final db = await _dbService.database;
    await db.insert('user_contacts', map);
  }

  Future<void> updateUserContact(UserContact userContact) async {
    final db = await _dbService.database;
    await db.update('user_contacts', userContact.toMap(), where: 'id = ?', whereArgs: [userContact.id]);
  }

  Future<void> deleteUserContact(int id) async {
    final db = await _dbService.database;
    await db.delete('user_contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteUserContactByUsername(String username) async {
    final db = await _dbService.database;
    await db.delete('user_contacts', where: 'username = ?', whereArgs: [username]);
  }
}
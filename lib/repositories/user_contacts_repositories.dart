import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/user_contact.dart';

class UserContactsRepositories {
  UserContactsRepositories._();
  static final UserContactsRepositories instance = UserContactsRepositories._();

  DatabaseService dbService = DatabaseService.instance;

  Future<List<UserContact>> getUserContact() async {
    final db = await dbService.database;

    final res = await db.query('user_contacts');
    return res.map((map) => UserContact.fromMap(map)).toList();
  }

  Future<void> addUserContact(Map<String, dynamic> map) async {
    final db = await dbService.database;
    await db.insert('user_contacts', map);
  }

  Future<void> updateUserContact(UserContact userContact) async {
    final db = await dbService.database;
    await db.update('user_contacts', userContact.toMap(), where: 'id = ?', whereArgs: [userContact.id]);
  }

  Future<void> deleteUserContact(int id) async {
    final db = await dbService.database;
    await db.delete('user_contacts', where: 'id = ?', whereArgs: [id]);
  }
}
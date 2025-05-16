import '../db/database.dart';

class AccountsApi {

  DatabaseService dbService = DatabaseService.instance;

  Future<void> createAccount(Map<String, dynamic> account) async {
    final db = await dbService.database;
    await db.insert('accounts', account);
  }

  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    final db = await dbService.database;
    return await db.query('accounts');
  }

  Future<void> updateAccount(Map<String, dynamic> account) async {
    final db = await dbService.database;
    await db.update('accounts', account, where: 'id = ?', whereArgs: [account['id']]);
  }

  Future<void> deleteAccount(int id) async {
    final db = await dbService.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getSelectedAccountBalance() async {
    final db = await dbService.database;
    final result = await db.query('accounts', where: 'includes_in_total = 1');
    double total = 0;
    if (result.isNotEmpty) {
      for (var row in result){
        total += row['balance'] as double;
      }
    }
    return total;
  }
}
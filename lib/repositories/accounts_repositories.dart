import '../db/database.dart';
import '../models/account.dart';

class AccountsApi {

  DatabaseService dbService = DatabaseService.instance;

  Future<void> createAccount(Account account) async {
    final db = await dbService.database;
    await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await dbService.database;
     List<Map<String, dynamic>> result = await db.query('accounts');
     return result.map((row) => Account(row)).toList();
  }

  Future<void> updateAccount(Account account) async {
    final db = await dbService.database;
    Map<String, dynamic> accountMap = account.toMap();
    await db.update('accounts', accountMap, where: 'id = ?', whereArgs: [accountMap['id']]);
  }

  Future<void> deleteAccount(Account account) async {
    final db = await dbService.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [account.id]);
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
import 'package:money_minder/db/database.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:sqflite/sqflite.dart' as sqf;
import 'package:money_minder/models/transaction.dart';

class TransactionsRepositories {
  DatabaseService dbService = DatabaseService.instance;

  Future<List<Transaction>> getTransactions() async {
    sqf.Database db = await dbService.database;
    List<Account> accounts = await AccountsRepository.instance.getAllAccounts();
    List<Map<String, dynamic>> res = await db.query('transactions');
    List<Transaction> transactions = [];
    for (Map<String, dynamic> r in res) {
      Account fromAccount= accounts.firstWhere((account) => account.id == r['from_account_id']);
      Account? toAccount = r['to_account_id'] == null
          ? null
          : accounts.firstWhere((account) => account.id == r['to_account_id']);
      transactions.add(Transaction.fromMap(r, fromAccount, toAccount));
    }
    return transactions;
  }
}
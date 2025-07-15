import 'package:mockito/annotations.dart'; // For @GenerateMocks

import 'package:money_minder/db/database.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';
import 'package:money_minder/repositories/category_repositories.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/repositories/transactions_repositories.dart';
import 'package:sqflite/sqflite.dart';

@GenerateMocks([
  DatabaseService,
  Database,
  Batch,
  TransactionsRepositories,
  RecurrenceRepositories,
  AccountsRepositories,
  CategoryRepositories,
])

void main() {
  /// for mocking purpose only
}
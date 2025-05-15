import 'dart:async';

import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  DatabaseService._privateConstructor();

  static final DatabaseService instance = DatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = '$databasesPath/money_minder.db';
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // Create the Account table
    await db.execute('''
          CREATE TABLE accounts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            balance REAL DEFAULT 0.0, -- Initial balance is 0.0
            icon TEXT, -- Storing icon codePoint as TEXT
            color TEXT, -- Storing color value (e.g., hex string)
            description TEXT,
            is_main INTEGER DEFAULT 0, -- Using INTEGER for boolean (0 for false, 1 for true)
            includes_in_total INTEGER DEFAULT 1 -- Using INTEGER for boolean (0 for false, 1 for true)
          )
        ''');

    // Create the Categories table
    await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT, -- Storing icon's codePoint as TEXT
            color TEXT, -- Storing color value (e.g., hex string)
            budget REAL DEFAULT 0.0,
          )
        ''');

    // Create the Transaction table
    await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT, -- Storing date as TEXT (ISO8601 format is recommended)
            type TEXT, -- e.g., 'expense', 'income', 'transfer'
            from_account_id INTEGER, -- Assuming foreign key to Account table
            to_account_id INTEGER, -- Assuming foreign key to Account table (for transfers)
            to_category_id INTEGER, -- Assuming foreign key to Categories table (for expenses/income)
            amount REAL, -- Using REAL for decimal amounts
            currency TEXT,
            amount2 REAL, -- Assuming this is for a second currency amount
            currency2 TEXT,
            note TEXT,
            FOREIGN KEY (from_account_id) REFERENCES accounts(id),
            FOREIGN KEY (to_account_id) REFERENCES accounts(id),
            FOREIGN KEY (to_category_id) REFERENCES categories(id)
          )
        ''');

    // Create the Sub Categories table
    await db.execute('''
          CREATE TABLE sub_categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT, -- Storing icon name or path as TEXT
            main_category_id INTEGER, -- Foreign key to Categories table
            FOREIGN KEY (main_category_id) REFERENCES categories(id)
          )
        ''');
  }
}

/// Get the database instance
//Database db = await DatabaseService.instance.database;

// Example: Insert a new item
// int id = await db.insert('items', {'name': 'New Item', 'value': 10});
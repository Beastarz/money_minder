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
            icon INTEGER, -- Storing icon codePoint
            color INTEGER, -- Storing color value
            description TEXT,
            is_main INTEGER DEFAULT 0, -- Using INTEGER for boolean (0 for false, 1 for true)
            includes_in_total INTEGER DEFAULT 1, -- Using INTEGER for boolean (0 for false, 1 for true)
            type TEXT NOT NULL, -- 'accounts'/ 'savings'
            currency TEXT DEFAULT 'sgd', -- 'sgd' / 'myr' for now
            position INTEGER NOT NULL
          )
        ''');

    // Create the Categories table
    await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            position INTEGER, -- the sequence of the category
            icon INTEGER, -- Storing icon's codePoint
            color INTEGER, -- Storing color value
            is_expense INTEGER NOT NULL DEFAULT 0 -- Using INTEGER for boolean (0 for false, 1 for true)
          )
        ''');

    // Create the Transaction table
    await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT, -- Storing date as TEXT (ISO8601 format)
            type TEXT, -- e.g., 'expense', 'income', 'transfer'
            from_account_id INTEGER, -- Assuming foreign key to Account table
            to_account_id INTEGER, -- Assuming foreign key to Account table (for transfers)
            to_category_id INTEGER, -- Assuming foreign key to Categories table (for expenses/income)
            amount REAL NOT NULL, -- Using REAL for decimal amounts
            currency TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (from_account_id) REFERENCES accounts(id),
            FOREIGN KEY (to_account_id) REFERENCES accounts(id),
            FOREIGN KEY (to_category_id) REFERENCES categories(id)
          )
        ''');

    // create empty recurrence table
    await db.execute('''
          CREATE TABLE recurrence(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT, -- Storing date as TEXT (ISO8601 format)
            type TEXT, -- e.g., 'expense', 'income', 'transfer'
            from_account_id INTEGER, -- Assuming foreign key to Account table
            to_account_id INTEGER, -- Assuming foreign key to Account table (for transfers)
            to_category_id INTEGER, -- Assuming foreign key to Categories table (for expenses/income)
            amount REAL NOT NULL, -- Using REAL for decimal amounts
            currency TEXT NOT NULL,
            note TEXT,
            recurrence_type TEXT NOT NULL,
            FOREIGN KEY (from_account_id) REFERENCES accounts(id),
            FOREIGN KEY (to_account_id) REFERENCES accounts(id),
            FOREIGN KEY (to_category_id) REFERENCES categories(id)
          )
        ''');

    // Create the Sub Categories table
    await db.execute('''
          CREATE TABLE fast_notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note TEXT NOT NULL,
            icon INTEGER, -- Storing icon name or path as TEXT
            category_id INTEGER, -- Foreign key to Categories table
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');

    // create the budget table
    await db.execute('''
          CREATE TABLE budgets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL, -- budget of the item (can be savings account or categories)
            month INTEGER, -- month of the budget (1 -> JAN, 2 -> FEB, ...)
            year INTEGER, -- year of the budget
            currency TEXT NOT NULL, -- the currency of the amount when it was recorded
            category_id INTEGER, -- foreign key to Categories table
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');

    // Create the currencies table
    await db.execute('''
          CREATE TABLE main_currency(
            name TEXT NOT NULL
          )
        ''');

    await db.execute('''
          CREATE TABLE date_filter(
            type TEXT NOT NULL,
            duration INTEGER -- Duration in days
          )
        ''');

    await db.execute('''
          CREATE TABLE passcode(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            salt TEXT NOT NULL,
            encrypted_passcode Text NOT NULL,
            active_period INTEGER NOT NULL
          )
        ''');

    await db.execute('''
          CREATE TABLE freeze_time(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            frozen_count INTEGER NOT NULL,
            frozen_until INTEGER NOT NULL
          )
        ''');

    await db.execute('''
          CREATE TABLE notification_time(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            time TEXT NOT NULL
          )
        ''');

    await db.execute('''
      INSERT INTO accounts (name, icon, balance, color, is_main, description, includes_in_total, type, currency, position) VALUES
      ('Main Account', 0xe850, 0.0, 0xFF48A8A8, 1, 'My active account', 1, 'accounts', 'sgd', 0), 
      ('Cash', 0xe850, 0.0, 0xFF708090, 0, 'My primary cash wallet', 1, 'accounts', 'sgd', 1),
      ('Savings Account', 0xe84f, 0.0, 0xFFF3C2B4, 0, 'Bank savings account', 1, 'savings', 'sgd', 2),
      ('Credit Card', 0xe870, 0.0, 0xFF800000, 0, 'Visa credit card', 1, 'debts', 'sgd', 3);
    ''');


    await db.execute('''
      INSERT INTO categories (name, position, icon, color, is_expense) VALUES
      ('Food', 2, 0xe56c, 0xFFA57D8E, 1), 
      ('Transport', 0, 0xe530, 0xFF5C7991, 1),
      ('Salary', 0, 0xe227, 0xFF5A785A, 0),
      ('Leisure', 1,  0xe30f, 0xFFD2B48C, 1),
      ('Grocery', 3, 0xe8cc, 0xFF8E6B8E, 1),
      ('Sport', 4, 0xe566, 0xFFE97451, 1);
    ''');

    await db.execute('''
      INSERT INTO main_currency (name) VALUES
      ('SGD');
    ''');

    await db.execute('''
      INSERT INTO date_filter (type) VALUES
      ('month');
    ''');
  }
}

/// Get the database instance
//Database db = await DatabaseService.instance.database;

// Example: Insert a new item
// int id = await db.insert('items', {'name': 'New Item', 'value': 10});
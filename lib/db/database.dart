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
            icon INTEGER, -- Storing icon codePoint as INTEGER
            color INTEGER, -- Storing color value (e.g., hex string)
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
            icon INTEGER, -- Storing icon's codePoint as TEXT
            color INTEGER, -- Storing color value (e.g., hex string)
            budget REAL DEFAULT 0.0
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
            icon INTEGER, -- Storing icon name or path as TEXT
            main_category_id INTEGER, -- Foreign key to Categories table
            FOREIGN KEY (main_category_id) REFERENCES categories(id)
          )
        ''');

    await db.execute('''
      INSERT INTO accounts (name, icon, balance, color, is_main, description, includes_in_total) VALUES
      ('Main Wallet', 0xe850, 1500.50, 0xFF4CAF50, 1, 'My primary cash wallet', 1), -- account_balance_wallet, Green
      ('Savings Account', 0xe53b, 5000.00, 0xFF2196F3, 0, 'Bank savings account', 1), -- account_balance, Blue
      ('Credit Card', 0xe870, -350.75, 0xFFF44336, 0, 'Visa credit card', 1), -- credit_card, Red
      ('Investment Fund', 0xeb4f, 10000.00, 0xFFFF9800, 0, 'Stock market investments', 0); -- trending_up, Orange (Exclude from total)
    ''');


    await db.execute('''
      INSERT INTO categories (name, icon, color, budget) VALUES
      ('Food', 0xe561, 0xFFFF5722, 300.00), -- restaurant, Deep Orange
      ('Transport', 0xf054f, 0xFF673AB7, 150.00), -- directions_bus, Deep Purple
      ('Salary', 0xe88f, 0xFF8BC34A, 0.00), -- attach_money, Light Green (Income category)
      ('Leisure', 0xe3e8, 0xFF00BCD4, 200.00); -- gamepad, Cyan
    ''');


    await db.execute('''
      INSERT INTO sub_categories (name, icon, main_category_id) VALUES
      ('Groceries', 0xe567, 1), -- shopping_cart (Belongs to Food)
      ('Restaurants', 0xe56c, 1), -- restaurant_menu (Belongs to Food)
      ('Public Transport', 0xe53d, 2), -- directions_transit (Belongs to Transport)
      ('Fuel', 0xe553, 2), -- local_gas_station (Belongs to Transport)
      ('Monthly Salary', 0xe88f, 3), -- attach_money (Belongs to Salary) - Using same icon as main category for simplicity
      ('Movies', 0xe40a, 4), -- movie (Belongs to Leisure)
      ('Hobbies', 0xe3f4, 4); -- games (Belongs to Leisure)
    ''');


    await db.execute('''
      INSERT INTO transactions (date, type, from_account_id, to_account_id, to_category_id, amount, currency, amount2, currency2, note) VALUES
      -- Expense: Groceries from Main Wallet
      ('2025-05-13', 'expense', 1, NULL, 1, 55.20, 'SGD', NULL, NULL, 'Weekly groceries'),
      -- Expense: Restaurant from Credit Card
      ('2025-05-14', 'expense', 3, NULL, 1, 30.50, 'SGD', NULL, NULL, 'Dinner with friends'),
      -- Income: Monthly Salary to Savings Account
      ('2025-05-15', 'income', NULL, 2, 3, 3500.00, 'SGD', NULL, NULL, 'May salary'),
      -- Transfer: From Main Wallet to Savings Account
      ('2025-05-15', 'transfer', 1, 2, NULL, 500.00, 'SGD', NULL, NULL, 'Transfer to savings'),
      -- Expense: Public Transport from Main Wallet
      ('2025-05-15', 'expense', 1, NULL, 2, 3.80, 'SGD', NULL, NULL, 'Bus fare'),
      -- Expense: Movie from Main Wallet (using Leisure category)
      ('2025-05-15', 'expense', 1, NULL, 4, 15.00, 'SGD', NULL, NULL, 'Movie ticket');
    ''');
  }
}

/// Get the database instance
//Database db = await DatabaseService.instance.database;

// Example: Insert a new item
// int id = await db.insert('items', {'name': 'New Item', 'value': 10});
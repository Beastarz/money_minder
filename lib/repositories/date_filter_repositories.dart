import 'package:sqflite/sqflite.dart';

import '../db/database.dart';
import '../models/date_filter.dart';

class DateFilterRepositories {
  DatabaseService dbService = DatabaseService.instance;

  DateFilterRepositories._privateConstructor();

  static DateFilterRepositories instance = DateFilterRepositories._privateConstructor();

  /// get date filter from database
  Future<DateFilter> getDateFilter() async {
    Database db = await dbService.database;

    List<Map<String, dynamic>> res = await db.query('date_filter');
    if (res.isNotEmpty) {
      return DateFilter.fromMap(res.first);
    }
    return DateFilter.fromType(DateFilterType.month);
  }

  /// get month date filter from database
  DateFilter getMonthDateFilter() {
    return DateFilter.fromType(DateFilterType.month);
  }

  /// update date filter to database
  Future<void> updateDateFilter(DateFilter dateFilter) async {
    Database db = await dbService.database;
    await db.rawDelete('DELETE FROM date_filter');
    await db.insert('date_filter', dateFilter.toMap());
  }
}
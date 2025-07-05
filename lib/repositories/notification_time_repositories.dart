import 'package:money_minder/db/database.dart';

import '../models/notification_time.dart';

class NotificationTimeRepositories {
  NotificationTimeRepositories._();
  static final NotificationTimeRepositories instance = NotificationTimeRepositories._();

  DatabaseService dbService = DatabaseService.instance;

  Future<NotificationTime?> getNotificationTime() async {
    final db = await dbService.database;
    final res = await db.query('notification_time');
    if (res.isEmpty) {
      return null;
    }
    return NotificationTime.fromMap(res.first);
  }

  Future<void> addNotificationTime(Map<String, dynamic> map) async {
    final db = await dbService.database;
    await db.insert('notification_time', map);
  }

  Future<void> updateNotificationTime(Map<String, dynamic> map) async {
    final db = await dbService.database;
    await db.update('notification_time', map);
  }

  Future<void> deleteNotificationTime() async {
    final db = await dbService.database;
    await db.delete('notification_time');
  }
}
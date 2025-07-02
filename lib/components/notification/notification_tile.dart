import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_minder/components/notification/notification_service.dart';

import '../../models/notification_time.dart';
import '../../repositories/notification_time_repositories.dart';

class NotificationTile extends StatefulWidget {
  const NotificationTile({super.key});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {

  TimeOfDay? _pickedTime;
  bool enabledNotification = false;

  void getTime() async {
    final NotificationTime? time = await NotificationTimeRepositories.instance.getNotificationTime();
    if (time == null) {
      return;
    }
    setState(() {
      _pickedTime = time.time;
      enabledNotification = true;
    });
  }

  void pickTime() async {

    // get the permissions
    if (!await NotificationService.requestPermissions()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification permissions not granted'),
          ),
        );
        await NotificationService.showPermissionDialog(context);
        return;
      }
    }

    List<PendingNotificationRequest> pendingNotifications = await NotificationService.getPendingNotifications();
    for (PendingNotificationRequest pendingNotification in pendingNotifications) {
      print(pendingNotification.id);
    }

    if (!mounted) { return;}
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? TimeOfDay.now(),
    );
    if (newTime == null) {
      setState(() {
        enabledNotification = _pickedTime != null;
      });
      return;
    }
    setState(() {
      _pickedTime = newTime;
      enabledNotification = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily notification time set to ${_pickedTime!.format(context)}'),
        ),
      );
    }
    await NotificationService.scheduleDailyNotification(_pickedTime!);
    await NotificationTimeRepositories.instance.deleteNotificationTime();
    await NotificationTimeRepositories.instance.addNotificationTime(NotificationTime.insertAsMap(_pickedTime!));
  }

  @override
  void initState() {
    super.initState();
    getTime();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: pickTime,
      title: Text('Notifications'),
      leading: Icon(
          enabledNotification
              ? Icons.notifications_active_outlined
              : Icons.notifications_none_outlined
      ),
      trailing: Switch(
        value: enabledNotification,
        onChanged: (enabled) {
          if (enabled) {
            pickTime();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Daily notification is disabled.'),
              ),
            );
            setState(() {
              _pickedTime = null;
            });
            NotificationTimeRepositories.instance.deleteNotificationTime();
            NotificationService.cancelAllNotifications();
          }
          setState(() {
            enabledNotification = enabled;
          });
        },
      ),
    );
  }
}

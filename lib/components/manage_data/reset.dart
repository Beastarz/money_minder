import 'package:flutter/material.dart';
import 'package:money_minder/repositories/fast_note_repositories.dart';
import 'package:money_minder/utils/restart_widget.dart';

import '../../repositories/accounts_repositories.dart';
import '../../repositories/budget_repositories.dart';
import '../../repositories/categories_repositories.dart';
import '../../repositories/notification_time_repositories.dart';
import '../../repositories/passcode_repositories.dart';
import '../../repositories/recurrence_repositories.dart';
import '../../repositories/transactions_repositories.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  Future<void> deleteAllData() async {
    await AccountsRepositories.instance.deleteAllNonMainAccounts();
    await BudgetRepositories.instance.deleteAllBudgets();
    await CategoriesRepositories.instance.deleteAllCategories();
    await FastNoteRepositories.instance.deleteAllFastNotes();
    await NotificationTimeRepositories.instance.deleteNotificationTime();
    await PasscodeRepositories.instance.deletePasscode();
    await RecurrenceRepositories.instance.deleteAllRecurrences();
    await TransactionsRepositories.instance.deleteAllTransactions();

    /// update the main account to default
    await AccountsRepositories.instance.resetMainAccount();

    /// restart the app
    if (mounted) {
      Navigator.of(context).pop(); // pop the alert dialog
      Navigator.of(context).pop(); // pop the manage_data_options
      RestartWidget.restartApp(context, "All data is reset. Restarting app...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('Reset'),
        leading: Icon(Icons.restart_alt_outlined),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Reset'),
                  content: Text('All data will be deleted permanently unless you have a backup. '
                      'This action is irreversible.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: deleteAllData,
                      child: Text('Confirm'),
                    ),
                  ],
                );
              }
          );
        }
    );
  }
}

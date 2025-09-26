import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_minder/components/manage_data/reset.dart';

import '../../firestore_repositories/accounts_repositories.dart';
import '../../firestore_repositories/categories_repositories.dart';
import '../../repositories/accounts_repositories.dart';
import '../../repositories/category_repositories.dart';
import '../../utils/app_message.dart';
import '../../utils/restart_widget.dart';
import 'firebase_data_helper.dart';

class RestoreData extends StatelessWidget {
  const RestoreData({
    super.key,
    required this.user,
  });

  final User? user;

  Future<void> restoreData(BuildContext context) async {

    AppMessage.showMessage(context, "Fetching data from server...");

    /// store the accounts and categories first
    List<Map<String, dynamic>> accounts = await FirebaseAccountsRepositories.instance.getAllAccounts(user!.uid);
    List<Map<String, dynamic>> categories = await FirebaseCategoriesRepositories.instance.getAllCategories(user!.uid);

    if (accounts.isEmpty || categories.isEmpty) {
      print("Account is empty: ${accounts.isEmpty}");
      print("Category is empty: ${categories.isEmpty}");
      if (context.mounted) {
        AppMessage.showMessage(context, "No data to restore");
        Navigator.of(context).pop();
      }
      return;
    }

    Reset.deleteAllData();

    await FirebaseDataHelper.addAccounts(accounts);
    await FirebaseDataHelper.addCategories(categories);

    /// get the new accounts and categories
    accounts = await AccountsRepositories.instance.getRawAccounts();
    categories = await CategoryRepositories.instance.getRawCategories();

    Map<String, int> accountMap = FirebaseDataHelper.accountToId(accounts);
    Map<String, int> categoryMap = FirebaseDataHelper.categoryToId(categories);

    await FirebaseDataHelper.addTransactions(accountMap, categoryMap, user!);
    await FirebaseDataHelper.addBudgets(categoryMap, user!);
    await FirebaseDataHelper.addFastNotes(categoryMap, user!);
    await FirebaseDataHelper.setMainCurrency(user!);

    if (context.mounted) {
      RestartWidget.restartApp(context, 'Your data has been successfully restored. Restarting app...');
      Navigator.of(context).pop(); // pop the alert dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('Restore data'),
        leading: Icon(Icons.restore_outlined),
        onTap: () {
          if (user == null) {
            Navigator.pop(context); // pop the manage tile alert
            Navigator.pop(context); // pop the app drawer
            AppMessage.showMessage(
                context, 'You must be signed in to restore data');
          } else {

            Navigator.pop(context); // pop the manage tile alert
            Navigator.pop(context); // pop the app drawer
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text('Restore Data'),
                      content: Text('It will overwrite your local data. '
                          'This action is irreversible.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // pop the alert dialog
                            AppMessage.showMessage(context, 'Restore data cancelled');
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await restoreData(context);
                          },
                          child: Text('Confirm'),
                        )
                      ]
                  );
                }
            );
          }
        }
    );
  }
}

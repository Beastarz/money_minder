import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_minder/components/manage_data/firebase_data_helper.dart';

import '../../firestore_repositories/accounts_repositories.dart';
import '../../firestore_repositories/budgets_repositories.dart';
import '../../firestore_repositories/categories_repositories.dart';
import '../../firestore_repositories/currencies_repositories.dart';
import '../../firestore_repositories/fast_notes_repositories.dart';
import '../../firestore_repositories/transactions_repositories.dart';
import '../../repositories/accounts_repositories.dart';
import '../../repositories/category_repositories.dart';
import '../../utils/app_message.dart';

class BackupData extends StatelessWidget {
  const BackupData({
    super.key,
    required this.user,
  });
  final User? user;

  Future<void> deletePreviousData() async {
    FirebaseAccountsRepositories.instance.deleteAllAccounts(user!.uid);
    FirebaseBudgetsRepositories.instance.deleteAllBudgets(user!.uid);
    FirebaseCategoriesRepositories.instance.deleteAllCategories(user!.uid);
    FirebaseCurrencyRepositories.instance.deleteMainCurrency(user!.uid);
    FirebaseTransactionsRepositories.instance.deleteAllTransactions(user!.uid);
    FirebaseFastNotesRepositories.instance.deleteAllFastNotes(user!.uid);
  }


  Future<void> backUpData() async {

    await deletePreviousData();

    List<Map<String, dynamic>> accounts = await AccountsRepositories.instance.getRawAccounts();
    List<Map<String, dynamic>> categories = await CategoryRepositories.instance.getRawCategories();

    Map<int, String> accountMap = FirebaseDataHelper.idToAccount(accounts);
    Map<int, String> categoryMap = FirebaseDataHelper.idToCategory(categories);

    await FirebaseAccountsRepositories.instance.addAllAccounts(user!.uid, accounts);
    await FirebaseBudgetsRepositories.instance.addAllBudgets(user!.uid, categoryMap);
    await FirebaseCategoriesRepositories.instance.addAllCategories(user!.uid, categories);
    await FirebaseCurrencyRepositories.instance.addMainCurrency(user!.uid);
    await FirebaseTransactionsRepositories.instance.addAllTransactions(user!.uid, accountMap, categoryMap);
    await FirebaseFastNotesRepositories.instance.addAllFastNotes(user!.uid, categoryMap);
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
        title: Text('Backup data'),
        leading: Icon(Icons.backup_outlined),
        onTap: () {

          if (user == null) {
            Navigator.pop(context); // pop the manage tile alert
            Navigator.pop(context); // pop the app drawer
            AppMessage.showMessage(
                context, 'You must be signed in to backup data');
          } else {
            Navigator.pop(context); // pop the manage tile alert
            Navigator.pop(context); // pop the app drawer
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Backup Data'),
                  content: Text('It will overwrite the previous data. '
                      'All upcoming transactions will not be recorded.'
                      'This action is irreversible.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // pop the alert dialog
                        AppMessage.showMessage(context, 'Backup data cancelled');
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // pop the alert dialog
                        backUpData();
                        AppMessage.showMessage(context, 'Your data has been successfully backed up.');
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

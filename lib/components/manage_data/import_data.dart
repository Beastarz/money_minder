import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/manage_data/csv_generator.dart';
import 'package:money_minder/utils/restart_widget.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/currency.dart';
import '../../models/transaction.dart';
import '../../repositories/accounts_repositories.dart';
import '../../repositories/category_repositories.dart';
import '../../repositories/transaction_helper.dart';
import '../../style/app_size.dart';
import '../../utils/app_message.dart';

class ImportData extends StatefulWidget {
  const ImportData({super.key});

  @override
  State<ImportData> createState() => _ImportDataState();
}

class _ImportDataState extends State<ImportData> {

  final int catCodePoint = 0xef64;
  final int accCodePoint = 0xf8ff;
  final Random _random = Random();

  PlatformFile? platformFile;

  Color generateRandomColor() {
    return Color.fromARGB(
      255, // Alpha (fully opaque)
      _random.nextInt(256), // Red (0-255)
      _random.nextInt(256), // Green (0-255)
      _random.nextInt(256), // Blue (0-255)
    );
  }

  List<List<dynamic>> generateSampleData() {
    return [
      ['Transactions'],
      ['Date (DDMMYYYY)', 'Type (expense/income/transfer)', 'From Account',
        'To Account/Category', 'Amount', 'Currency (ISO 4217 - Currency Code)', 'Note']
    ];
  }

  int getPosition(bool isExpense, List<Category> categories) {
    for (int i = categories.length - 1; i >= 0; i--) {
      if (categories[i].isExpense == isExpense) {
        return categories[i].position + 1;
      }
    }
    return 0;
  }

  Future<void> importData() async {

    // existing account and category
    Map<String, Account> accountMap = await CSVGenerator.getMap<Account>(isAcc: true);
    Map<String, Category> categoryMap = await CSVGenerator.getMap<Category>(isCat: true);

    // new accounts and category
    Set<String> newAccounts = {};
    Set<String> newExpCat = {};
    Set<String> newIncCat = {};
    List<Map<String, dynamic>> newTransactions = [];

    try {

      File file = File(platformFile!.path!);
      List<List<dynamic>> data = [];
      List<String> lines;

      if (platformFile!.extension == 'csv') {

        lines = await file.readAsLines();

      } else if (platformFile!.extension == 'docx') {

        final Uint8List bytes = await file.readAsBytes();
        final String textContent = docxToText(bytes);
        lines = textContent.split('\n');

      } else {

        throw FormatException('Invalid format');

      }

      for (String line in lines.sublist(2)) {
        data.add(line.split(','));
      }

      // two lines for transaction header
      int index = 0;
      while (index < data.length) {
        if (data[index][0].toString().isEmpty) {
          // end of transaction
          break;
        }
        List<dynamic> row = data[index];

        if (row.sublist(0, 6).any((item) => item.toString().isEmpty)) {
          throw FormatException('Invalid format');
        }

        /// get the date
        String date = row[0];

        /// get the transaction type
        TransactionType type = CSVGenerator.transactionStringToType[row[1].toLowerCase()]!;

        /// differentiate existing categories and accounts
        String from = row[2];
        String to = row[3];
        if (!accountMap.containsKey(from.toLowerCase())) {
          newAccounts.add(from);
        }
        if (type == TransactionType.transfer) {
          if (!accountMap.containsKey(to.toLowerCase())) {
            newAccounts.add(to);
          }
        } else {
          if (!categoryMap.containsKey(to.toLowerCase())) {
            if (type == TransactionType.expense) {
              newExpCat.add(to);
            } else {
              newIncCat.add(to);
            }
          }
        }

        /// add new transactions
        newTransactions.add({
          'date': DateTime(int.parse(date.substring(4, 8)), int.parse(date.substring(2, 4)), int.parse(date.substring(0, 2))),
          'type': type,
          'from_account': row[2],
          'to_account': type == TransactionType.transfer ? to : null,
          'to_category': type != TransactionType.transfer ? to : null,
          'amount': double.parse(row[4]),
          'currency': Currency.of(row[5].toLowerCase()),
          'note': row[6],
        });
        index++;
      }

    } catch (e) {
      if (mounted) {
        AppMessage.showMessage(context, 'Import Data failed. Invalid format.');
      }
      return;
    }

    /// save new expense category
    int expPos = getPosition(true, categoryMap.values.toList());
    for (String name in newExpCat) {
      await CategoryRepositories.instance.createCategory(
          Category.insertAsMap(
              name: name,
              position: expPos++,
              codePoint: catCodePoint,
              colorValue: generateRandomColor().toARGB32(),
              isExpense: true)
      );
    }

    /// save new income category
    int incPos = getPosition(false, categoryMap.values.toList());
    for (String name in newIncCat) {
      await CategoryRepositories.instance.createCategory(
          Category.insertAsMap(
              name: name,
              position: incPos++,
              codePoint: catCodePoint,
              colorValue: generateRandomColor().toARGB32(),
              isExpense: false)
      );
    }

    /// save new accounts
    for (String name in newAccounts) {
      await AccountsRepositories.instance.createAccount(
          Account.insertAsMap(
              name: name,
              icon: Icon(IconData(accCodePoint, fontFamily: "MaterialSymbolsOutlined")),
              color: generateRandomColor(),
              balance: 0,
              isIncludesInTotal: true,
              type: AccountType.accounts,
              currency: Currency.of('sgd'),
              description: '',
          )
      );
    }

    /// get the accounts and categories again after saving new ones
    accountMap = await CSVGenerator.getMap<Account>(isAcc: true);
    categoryMap = await CSVGenerator.getMap<Category>(isCat: true);
    for (Map<String, dynamic> transaction in newTransactions) {
      if (transaction['type'] == TransactionType.transfer) {
        await TransactionHelper.proceedTransfer(
            transaction['date'],
            accountMap[transaction['from_account'].toLowerCase()]!.id,
            accountMap[transaction['to_account'].toLowerCase()]!.id,
            transaction['amount'],
            transaction['currency'],
            transaction['note']
        );
      } else {
        await TransactionHelper.proceedExpense(
            transaction['date'],
            accountMap[transaction['from_account'].toLowerCase()]!.id,
            categoryMap[transaction['to_category'].toLowerCase()]!,
            transaction['amount'],
            transaction['currency'],
            transaction['note']
        );
      }
    }

    if (mounted) {
      RestartWidget.restartApp(context, 'Data imported successfully! Restart App...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text('Import Data'),
        leading: Icon(Icons.download_outlined),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSize.borderRadius),
              topRight: Radius.circular(AppSize.borderRadius)
          ),
        ),
        onTap: () {

          /// Only import transactions is supported
          showDialog(
              context: context,
              builder: (dialogContext) => Dialog(
                child: Container(
                  padding: EdgeInsets.all(AppSize.smallPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Import Data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSize.heading1,
                        ),
                      ),
                      SizedBox(height: AppSize.smallPadding),
                      Text(
                        "Please strictly follow the format of sample data",
                        style: TextStyle(
                          fontSize: AppSize.heading3,
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Select File'),
                        leading: Icon(Icons.manage_search_outlined),
                        onTap: () async {
                          platformFile = await CSVGenerator.readFile(dialogContext);
                          bool? confirmed = false;
                          if (dialogContext.mounted) {
                            Navigator.pop(context);
                            while (!confirmed! && platformFile != null) {
                              String fileName = platformFile!.name;
                              confirmed = await showDialog<bool>(
                                context: context,
                                builder: (alertContext) => AlertDialog(
                                  title: Text('Selected file:'),
                                  content: Text(fileName),
                                  actions: [
                                    TextButton(
                                      child: Text('Select Other'),
                                      onPressed: () async {
                                        platformFile = await CSVGenerator.readFile(context);
                                        if (context.mounted) {
                                          Navigator.of(alertContext).pop(false);
                                        }
                                      }
                                    ),
                                    TextButton(
                                        child: Text('Continue'),
                                        onPressed: () async {
                                          Navigator.of(alertContext).pop(true);
                                        }
                                    ),
                                  ]
                                )
                              );
                              if (confirmed == null) {
                                // user cancelled import file
                                if (context.mounted) {
                                  AppMessage.showMessage(context, 'File import cancelled.');
                                }
                                break;
                              }
                            }
                            if (confirmed != null && confirmed && platformFile != null) {
                              await importData();
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      ),
                      ListTile(
                        title: Text("Download Sample Data"),
                        leading: Icon(Icons.download_outlined),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(AppSize.borderRadius),
                                bottomRight: Radius.circular(AppSize.borderRadius)
                            ),
                          ),
                        onTap: () async {
                          await CSVGenerator.generateCSV(
                              data: generateSampleData(),
                              fileName: 'Sample_Data',
                              context: dialogContext
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            Navigator.pop(dialogContext);
                          }
                        }
                      )
                    ],
                  )
                )
              )
          );
        }
    );
  }
}

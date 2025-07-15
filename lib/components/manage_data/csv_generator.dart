import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../repositories/accounts_repositories.dart';
import '../../repositories/category_repositories.dart';
import '../../utils/app_message.dart';

class CSVGenerator {

  static final Map<TransactionType, String> transferTypeToString = {
    TransactionType.transfer: 'Transfer',
    TransactionType.income: 'Income',
    TransactionType.expense: 'Expense',
  };

  static final Map<AccountType, String> accountTypeToString = {
    AccountType.accounts: 'Account',
    AccountType.savings: 'Savings',
    AccountType.debts: 'Debt',
  };

  static final Map<String, TransactionType> transactionStringToType = {
    'transfer': TransactionType.transfer,
    'income': TransactionType.income,
    'expense': TransactionType.expense,
  };

  static final Map<String, AccountType> accountStringToType = {
    'account': AccountType.accounts,
    'savings': AccountType.savings,
    'debt': AccountType.debts,
  };

  static Future<Map<String, T>> getMap<T>({isAcc = false, isCat = false}) async {
    Map<String, T> map = {};
    if (isAcc) {
      List<Account> accounts = await AccountsRepositories.instance.getAllAccounts();
      for (Account account in accounts) {
        map[account.name.toLowerCase()] = account as T;
      }
    }
    if (isCat) {
      List<Category> categories = await CategoryRepositories.instance.getAllCategories();
      for (Category category in categories) {
        map[category.name.toLowerCase()] = category as T;
      }
    }
    return map;
  }

  // Generate CSV file and save to app's documents directory
  static Future<void> generateCSV({
    required List<List<dynamic>> data,
    required String fileName,
    required BuildContext context,
    String delimiter = ',',
  }) async {
    try {

      String csvContent = ListToCsvConverter(
        fieldDelimiter: delimiter,
        eol: '\n',
      ).convert(data);

      // Convert the CSV string to bytes (Uint8List)
      final Uint8List bytes = Uint8List.fromList(csvContent.codeUnits);

      // Let user choose save location
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV Export',
        fileName: '$fileName.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: bytes,
      );

      if (outputFile != null) {
        if (context.mounted) {
          AppMessage.showMessage(context, 'File is saved successfully!');
        }
      } else {
        if (context.mounted) {
          AppMessage.showMessage(context, 'File save cancelled.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppMessage.showMessage(context, 'Generate CSV file fail!');
      }
    }
  }

  // Check if file exists
  static Future<bool> fileExists(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.csv';
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  // Get file size
  static Future<int> getFileSize(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.csv';
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Read CSV file
  static Future<PlatformFile?> readFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.custom,
        // allowedExtensions: ['csv'] // only csv file is accepted
      );

      if (result != null) {

        // file is selected correctly
        if (context.mounted) {
          AppMessage.showMessage(context, 'File is imported, please wait...');
        }
        return result.files.single;
      } else {
        // User canceled the picker
        if (context.mounted) {
          AppMessage.showMessage(context, 'File import cancelled.');
        }

        // cancelled, return empty list
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        AppMessage.showMessage(context, 'Import CSV file fail!');
      }
      return null;
    }
  }
}
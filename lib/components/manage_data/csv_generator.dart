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
import '../../repositories/categories_repositories.dart';
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
      List<Category> categories = await CategoriesRepositories.instance.getAllCategories();
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File is saved successfully!'),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File save cancelled.'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generate CSV file fail!'),
          ),
        );
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

  // Delete CSV file
  static Future<bool> deleteCSV(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.csv';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ File deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  // Append data to existing CSV
  static Future<void> appendToCSV(String fileName, List<List<dynamic>> newData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.csv';

      // Convert new data to CSV format
      String csvString = const ListToCsvConverter().convert(newData);

      // Append to existing file
      final file = File(filePath);
      await file.writeAsString(csvString, mode: FileMode.append);

      print('📝 Data appended to CSV file');
    } catch (e) {
      print('❌ Error appending to CSV: $e');
      rethrow;
    }
  }
}
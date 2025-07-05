import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/account.dart';
import '../../models/transaction.dart';

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
  static Future<List<List<dynamic>>> readCSV(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.csv';
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        return const CsvToListConverter().convert(contents);
      }
      return [];
    } catch (e) {
      print('❌ Error reading CSV file: $e');
      return [];
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
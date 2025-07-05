import 'package:flutter/material.dart';
import 'package:money_minder/components/manage_data/csv_generator.dart';

import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../repositories/accounts_repositories.dart';
import '../../repositories/transactions_repositories.dart';

class ExportData extends StatefulWidget {
  const ExportData({super.key});

  @override
  State<ExportData> createState() => _ExportDataState();
}

class _ExportDataState extends State<ExportData> {

  List<Account> accounts = [];
  List<Transaction> transactions = [];

  String formattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.year}';
  }

  Future<List<List<dynamic>>> generateData() async {
    List<List<dynamic>> data = [];
    data.addAll(await generateTransactionData());
    data.addAll([[], []]); // Empty lines to separate transactions and accounts
    data.addAll(await generateAccountData());
    return data;
  }

  Future<List<List<dynamic>>> generateTransactionData() async {

    transactions.sort((a, b) => b.date.compareTo(a.date));

    List<List<dynamic>> transactionList = [
      ['Transactions'],
      ['Date', 'Type', 'From Account', 'To Account/Category', 'Amount', 'Currency', 'Note'],
    ];

    for (Transaction transaction in transactions) {
      transactionList.add(
        [
          formattedDate(transaction.date),
          CSVGenerator.transferTypeToString[transaction.type],
          transaction.fromAccount.name,
          transaction.toAccount != null ? transaction.toAccount!.name : transaction.toCategory!.label,
          transaction.amount,
          transaction.currency.currency().name.toUpperCase(),
          transaction.note,
        ]
      );
    }

    return transactionList;
  }

  Future<List<List<dynamic>>> generateAccountData() async {
    List<List<dynamic>> accountList = [
      ['Accounts'],
      ['Name', 'Type', 'Balance', 'Currency', 'Description'],
    ];

    for (Account account in accounts) {
      accountList.add(
        [
          account.name,
          CSVGenerator.accountTypeToString[account.type],
          account.balance,
          account.currency.currency().name.toUpperCase(),
          account.description,
        ]
      );
    }

    return accountList;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: const Text('Export Data'),
        leading: const Icon(Icons.download_outlined),
        onTap: () async {

          accounts = await AccountsRepositories.instance.getAllAccounts();
          transactions = await TransactionsRepositories.instance.getTransactions();
          final List<List<dynamic>> data = await generateData();

          if (context.mounted) {
            await CSVGenerator.generateCSV(
                data: data,
                fileName: "MoneyMinder_${formattedDate(DateTime.now())}",
                context: context
            );
          }
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
    );
  }
}

import 'package:money_minder/models/transaction.dart';

class TransactionFilter {
  List<int> accountIds;
  List<int> categoryIds;
  List<TransactionType> transactionTypes;
  String notePrefix;
  bool isOff;

  TransactionFilter({
    required this.accountIds,
    required this.categoryIds,
    required this.transactionTypes,
    required this.notePrefix,
    this.isOff = false,
  });

  factory TransactionFilter.empty() {
    return TransactionFilter(accountIds: [], categoryIds: [], transactionTypes: [], notePrefix: '', isOff: true);
  }

  List<Transaction> filterTransactions(List<Transaction> transactions) {
    if (isOff) {
      return transactions;
    }
    List<Transaction> res = [];
    for (int id in accountIds) {
      res.addAll(transactions.where((t) => t.fromAccount.id == id || t.toAccount?.id == id));
    }
    for (int id in categoryIds) {
      res.addAll(transactions.where((t) => t.toCategory?.id == id));
    }
    for (TransactionType type in transactionTypes) {
      res.addAll(transactions.where((t) => t.type == type));
    }
    if (notePrefix.isNotEmpty) {
      res.addAll(transactions.where((t) => t.note.startsWith(notePrefix)));
    }
    return res.toSet().toList();
  }

  int count() {
    return accountIds.length + categoryIds.length + transactionTypes.length;
  }
}
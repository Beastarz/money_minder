import 'package:money_minder/models/transaction.dart';

import 'account.dart';
import 'category.dart';
import 'currency.dart';

enum RecurrenceType {
  none,
  daily,
  weekly,
  weekday,
  weekend,
  monthly,
  yearly,
}

RecurrenceType stringToRecurrenceType(String recurrenceType) {
  switch (recurrenceType) {
    case 'none':
      return RecurrenceType.none;
    case 'daily':
      return RecurrenceType.daily;
    case 'weekly':
      return RecurrenceType.weekly;
    case 'weekday':
      return RecurrenceType.weekday;
    case 'weekend':
      return RecurrenceType.weekend;
      case 'monthly':
      return RecurrenceType.monthly;
    case 'yearly':
      return RecurrenceType.yearly;
    default:
      throw Exception('Invalid recurrence type: $recurrenceType');
  }
}

class Recurrence extends Transaction {
  RecurrenceType recurrenceType;

  Recurrence({
    required super.id,
    required super.date,
    required super.type,
    required super.fromAccount,
    required super.toAccount,
    required super.toCategory,
    required super.amount,
    required super.currency,
    required super.mainCurrency,
    required super.note,
    required this.recurrenceType
  });

  factory Recurrence.fromMap(Map<String, dynamic> map, Account fromAccount, Account? toAccount, Category? category, Currency mainCurrency) {
    Recurrence temp = Recurrence(
        id: map['id'],
        date: DateTime.parse(map['date']),
        type: map['type'] == 'expense'
            ? TransactionType.expense
            : map['type'] == 'transfer'
            ? TransactionType.transfer
            : TransactionType.income,
        fromAccount: fromAccount,
        toAccount: toAccount,
        toCategory: category,
        amount: map['amount'],
        currency: Currency.of(map['currency']),
        mainCurrency: mainCurrency,
        note: map['note'],
        recurrenceType: stringToRecurrenceType(map['recurrence_type'])
    );
    if (temp.recurrenceType == RecurrenceType.weekday) {
      if (temp.date.weekday == DateTime.saturday || temp.date.weekday == DateTime.sunday) {
        temp = temp.increment();
      }
    } else if (temp.recurrenceType == RecurrenceType.weekend) {
      if (temp.date.weekday != DateTime.saturday && temp.date.weekday != DateTime.sunday) {
        temp = temp.increment();
      }
    }
    return temp;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'from_account_id': fromAccount.id,
      'to_account_id': toAccount?.id,
      'to_category_id': toCategory?.id,
      'amount': amount,
      'currency': currency
          .currency()
          .name,
      'note': note,
      'recurrence_type': recurrenceType.name
    };
  }

  get isNone => recurrenceType == RecurrenceType.none;
  get isOverdue => date.isBefore(DateTime.now()) || date.isAtSameMomentAs(DateTime.now());

  Map<String, dynamic> toTransactionMap() {
    return Transaction.insertAsMap(
        date: date,
        type: type,
        fromAccountId: fromAccount.id,
        toCategoryId: toCategory?.id,
        toAccountId: toAccount?.id,
        amount: amount,
        currency: currency,
        note: note
    );
  }

  Recurrence increment() {
    DateTime newDate;
    switch (recurrenceType) {
      case RecurrenceType.daily:
        newDate = date.add(const Duration(days: 1));
        break;
      case RecurrenceType.weekly:
        newDate = date.add(const Duration(days: 7));
        break;
      case RecurrenceType.weekday:
        newDate = date.add(const Duration(days: 1));
        while (newDate.weekday == DateTime.saturday || newDate.weekday == DateTime.sunday) {
          newDate = newDate.add(const Duration(days: 1));
        }
      case RecurrenceType.weekend:
        newDate = date.add(const Duration(days: 1));
        while (newDate.weekday != DateTime.saturday && newDate.weekday != DateTime.sunday) {
          newDate = newDate.add(const Duration(days: 1));
        }
      case RecurrenceType.monthly:
        newDate = DateTime(date.year, date.month + 1, date.day);
      case RecurrenceType.yearly:
        newDate = DateTime(date.year + 1, date.month, date.day);
      default:
        throw Exception('Invalid recurrence type: $recurrenceType');
    }
    return Recurrence(
        id: id,
        date: newDate,
        type: type,
        fromAccount: fromAccount,
        toAccount: toAccount,
        toCategory: toCategory,
        amount: amount,
        currency: currency,
        mainCurrency: mainCurrency,
        note: note,
        recurrenceType: recurrenceType
    );
  }

  static Map<String, dynamic> insertAsMap({
    required DateTime date,
    required TransactionType type,
    required int fromAccountId,
    int? toAccountId,
    int? toCategoryId,
    required double amount,
    required Currency currency,
    required String note,
    required RecurrenceType recurrenceType,
  }) {
    if (toAccountId == null && toCategoryId == null) {
      throw Exception('toAccountId and toCategoryId cannot be null at the same time');
    }
    DateTime d = DateTime(date.year, date.month, date.day);

    return {
      'date': d.toIso8601String(),
      'type': type.name,
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'to_category_id': toCategoryId,
      'amount': amount,
      'currency': currency
          .currency()
          .name,
      'note': note,
      'recurrence_type': recurrenceType.name,
    };
  }

  @override
  Recurrence copyWith({
    DateTime? date,
    Account? fromAccount,
    Account? toAccount,
    Category? toCategory,
    double? amount,
    Currency? currency,
    String? note,
    RecurrenceType? recurrenceType,
  }) {
    return Recurrence(
      id: id,
      date: date ?? this.date,
      type: type,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      toCategory: toCategory ?? this.toCategory,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      mainCurrency: mainCurrency,
      note: note ?? this.note,
      recurrenceType: recurrenceType ?? this.recurrenceType,
    );
  }
}
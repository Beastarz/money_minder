import 'package:flutter/material.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/utils/account_top_card.dart';
import 'package:money_minder/utils/category_top_card.dart';
import 'package:money_minder/repositories/transaction_helper.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';

import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../repositories/recurrence_repositories.dart';
import '../../style/app_size.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/input_keyboard.dart';

class EditExpenseSheet extends StatefulWidget {
  const EditExpenseSheet({super.key, required this.onEditTransactionReload, required this.oldTransaction });

  final Transaction oldTransaction;
  final void Function() onEditTransactionReload;

  @override
  State<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends State<EditExpenseSheet> {
  late Account fromAccount;
  late Category toCategory;
  late Currency currency;
  late Transaction newTransaction;

  @override
  void initState() {
    super.initState();
    toCategory = widget.oldTransaction.toCategory!;
    fromAccount = widget.oldTransaction.fromAccount;
    currency = widget.oldTransaction.currency;
    newTransaction = widget.oldTransaction;
  }

  @override
  Widget build(BuildContext context) {
    bool isExpense = toCategory.isExpense;

    // left card on top of the input form
    CategoryTopCard categoryCard = CategoryTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topRight: isExpense,
      initialCategory: toCategory,
      onPressed: (Category category) {
        setState(() {
          toCategory = category;
        });
      },
    );

    // right card on top of the input form
    Widget accountCard =  AccountTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topLeft: isExpense,
      initialAccount: fromAccount,
      onPressed: (Account account) {
        setState(() {
          fromAccount = account;
        });
      },
    );


    return SafeArea(
      child: InputFormSheet(
        // Define the button layout as seen in the image
          inputForm: InputKeyboard(
              buttonProps: InputFormHelper.convertToCalButProps([
                '÷', '7', '8', '9', 'C',
                'x', '4', '5', '6', '<',
                '-', '1', '2', '3', 'calendar',
                '+', '\$', '0', '.',
              ], {
                '<': Icons.backspace_outlined,
                'calendar': Icons.calendar_month,
                '✓': Icons.check,
              }
              ),
              mainCurrency: currency,
              onSubmit: (DateTime date, double amount, String note, int recurringMonths, RecurrenceType recurrenceType) {
                _handleSubmit(date, fromAccount, toCategory, amount, currency, note, recurrenceType);
                Navigator.pop(context);
              },
              defaultValue: widget.oldTransaction.amount,
              defaultDate: widget.oldTransaction.date,
              onCurrencyUpdate: (Currency currency) {
                setState(() {
                  this.currency = currency;
                });
              },
              category: toCategory,
          ),
          topContent: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSize.borderRadius)
              ),
            ),
            child: Row(
                children: isExpense ? [accountCard, categoryCard] : [categoryCard, accountCard]
            ),
          )
      ),
    );
  }

  void _handleSubmit(DateTime date, Account fromAccount, Category toCategory, double amount, Currency currency, String note, RecurrenceType recurrenceType) async {
    if (recurrenceType == RecurrenceType.none && (date.isBefore(DateTime.now()) || date.isAtSameMomentAs(DateTime.now()))) {
      await TransactionHelper.editExpense(
          widget.oldTransaction,
          date,
          fromAccount.id,
          toCategory,
          amount,
          currency,
          note);
    } else {
      TransactionHelper.deleteExpense(widget.oldTransaction);
      await RecurrenceRepositories.instance.createRecurrence(Recurrence.insertAsMap(
          date: date,
          type: toCategory.isExpense ? TransactionType.expense : TransactionType.income,
          fromAccountId: fromAccount.id,
          toCategoryId: toCategory.id,
          amount: amount,
          currency: currency,
          note: note,
          recurrenceType: recurrenceType
      ));
    }
    widget.onEditTransactionReload();
  }
}

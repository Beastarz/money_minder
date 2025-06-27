import 'package:flutter/material.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/repositories/recurrence_repositories.dart';
import 'package:money_minder/utils/account_top_card.dart';
import 'package:money_minder/utils/category_top_card.dart';
import 'package:money_minder/repositories/transaction_helper.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../models/category.dart';
import '../../style/app_size.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/input_keyboard.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key, required this.mainCurrency, required this.toCategory, required this.onAddTransactionReload, required this.defaultDate });

  final Currency mainCurrency;
  final Category toCategory;
  final DateTime defaultDate;
  final void Function() onAddTransactionReload;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  Account? fromAccount;
  late Category toCategory;
  late Currency currency;

  @override
  void initState() {
    super.initState();
    _fetchMainAccount();
    toCategory = widget.toCategory;
    currency = widget.mainCurrency;
  }

  Future<void> _fetchMainAccount() async {
    Account res = await AccountsRepositories.instance.getMainAccounts();
    setState(() {
      fromAccount = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isExpense = widget.toCategory.isExpense;

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
    Widget accountCard = fromAccount == null ? Container() : AccountTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topLeft: isExpense,
      initialAccount: fromAccount!,
      onPressed: (Account account) {
        setState(() {
          fromAccount = account;
        });
      },
    );


    return InputFormSheet(
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
          defaultDate: widget.defaultDate,
          onSubmit: (DateTime date, double amount, String note, int recurringMonths, RecurrenceType recurrenceType) {
            _handleSubmit(date, fromAccount!, toCategory, amount, currency, note, recurrenceType);
            Navigator.pop(context);
          },
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
    );
  }

  void _handleSubmit(DateTime date, Account fromAccount, Category toCategory, double amount, Currency currency, String note, RecurrenceType recurrenceType) async {
    if (recurrenceType == RecurrenceType.none &&
        (date.isBefore(DateTime.now()) ||
            date.isAtSameMomentAs(DateTime.now()))) {
      await TransactionHelper.proceedExpense(
          date, fromAccount.id, toCategory, amount, currency, note);
    } else {
      await RecurrenceRepositories.instance.createRecurrence(
          Recurrence.insertAsMap(
              date: date,
              type: toCategory.isExpense ? TransactionType.expense : TransactionType.income,
              fromAccountId: fromAccount.id,
              toCategoryId: toCategory.id,
              amount: amount,
              currency: currency,
              note: note,
              recurrenceType: recurrenceType));
    }
    widget.onAddTransactionReload();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/utils/account_top_card.dart';
import 'package:money_minder/utils/category_top_card.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';

import '../../models/category.dart';
import '../../repositories/recurrence_repositories.dart';
import '../../style/app_size.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/input_keyboard.dart';

class EditRecurrenceSheet extends StatefulWidget {
  const EditRecurrenceSheet({super.key, required this.onEditTransactionReload, required this.oldRecurrence });

  final Recurrence oldRecurrence;
  final void Function() onEditTransactionReload;

  @override
  State<EditRecurrenceSheet> createState() => _EditRecurrenceSheetState();
}

class _EditRecurrenceSheetState extends State<EditRecurrenceSheet> {
  late Account fromAccount;
  late Category toCategory;
  late Currency currency;
  late Recurrence newRecurrence;

  @override
  void initState() {
    super.initState();
    toCategory = widget.oldRecurrence.toCategory!;
    fromAccount = widget.oldRecurrence.fromAccount;
    currency = widget.oldRecurrence.currency;
    newRecurrence = widget.oldRecurrence;
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
              defaultValue: widget.oldRecurrence.amount,
              defaultDate: widget.oldRecurrence.date,
              defaultRecurrence: widget.oldRecurrence.recurrenceType,
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
                  top: Radius.circular(AppSize.borderRadius.r)
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
    RecurrenceRepositories.instance.updateRecurrence(newRecurrence.copyWith(
      date: date,
      fromAccount: fromAccount,
      toCategory: toCategory,
      amount: amount,
      currency: currency,
      note: note,
      recurrenceType: recurrenceType
    ));
    widget.onEditTransactionReload();
  }
}

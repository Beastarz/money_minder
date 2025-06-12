import 'package:flutter/material.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/utils/account_top_card.dart';
import 'package:money_minder/components/transaction/transaction_helper.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';

import '../../models/recurrence.dart';
import '../../repositories/recurrence_repositories.dart';
import '../../style/app_size.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/input_keyboard.dart';

class AddTransferSheet extends StatefulWidget {
  const AddTransferSheet({super.key, required this.mainCurrency, required this.onAddTransactionReload, required this.fromAccount, required this.toAccount});

  final Currency mainCurrency;
  final Account fromAccount;
  final Account toAccount;
  final void Function() onAddTransactionReload;

  @override
  State<AddTransferSheet> createState() => _AddTransferSheetState();
}

class _AddTransferSheetState extends State<AddTransferSheet> {
  late Account fromAccount;
  late Account toAccount;
  late Currency currency;

  @override
  void initState() {
    super.initState();
    fromAccount = widget.fromAccount;
    toAccount = widget.toAccount;
    currency = widget.mainCurrency;
  }


  @override
  Widget build(BuildContext context) {

    // left card on top of the input form
    AccountTopCard fromAccountCard = AccountTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topLeft: true,
      initialAccount: fromAccount,
      onPressed: (Account account) {
        setState(() {
          fromAccount = account;
        });
      },
    );

    // right card on top of the input form
    AccountTopCard toAccountCard = AccountTopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topRight: true,
      initialAccount: toAccount,
      onPressed: (Account account) {
        setState(() {
          toAccount = account;
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
            onSubmit: (DateTime date, double amount, String note, int recurringMonths, RecurrenceType recurrenceType) {
              _handleSubmit(date, fromAccount, toAccount, amount, currency, note, recurrenceType);
              Navigator.pop(context);
            },
            onCurrencyUpdate: (Currency currency) {
              setState(() {
                this.currency = currency;
              });
            }
        ),
        topContent: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSize.borderRadius)
            ),
          ),
          child: Row(
              children: [fromAccountCard, toAccountCard]
          ),
        )
    );
  }

  void _handleSubmit(DateTime date, Account fromAccount, Account toAccount, double amount, Currency currency, String note, RecurrenceType recurrenceType) async {
    if (recurrenceType == RecurrenceType.none &&
        (date.isBefore(DateTime.now()) ||
            date.isAtSameMomentAs(DateTime.now()))) {
      await TransactionHelper.proceedTransfer(
          date, fromAccount.id, toAccount.id, amount, currency, note);
    } else {
      await RecurrenceRepositories.instance.createRecurrence(
          Recurrence.insertAsMap(
              date: date,
              type: TransactionType.transfer,
              fromAccountId: fromAccount.id,
              toAccountId: toAccount.id,
              amount: amount,
              currency: currency,
              note: note,
              recurrenceType: recurrenceType));
    }
    widget.onAddTransactionReload();
  }
}

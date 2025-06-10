import 'package:flutter/material.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/models/transaction.dart';
import 'package:money_minder/utils/account_top_card.dart';
import 'package:money_minder/components/transaction/transaction_helper.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';

import '../../style/app_size.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/input_keyboard.dart';

class EditTransferSheet extends StatefulWidget {
  const EditTransferSheet({super.key, required this.onAddTransactionReload, required this.oldTransaction});

  final Transaction oldTransaction;
  final void Function() onAddTransactionReload;

  @override
  State<EditTransferSheet> createState() => _EditTransferSheetState();
}

class _EditTransferSheetState extends State<EditTransferSheet> {
  late Account fromAccount;
  late Account toAccount;
  late Currency currency;

  @override
  void initState() {
    super.initState();
    toAccount = widget.oldTransaction.toAccount!;
    fromAccount = widget.oldTransaction.fromAccount;
    currency = widget.oldTransaction.currency;
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
            defaultValue: widget.oldTransaction.amount,
            defaultDate: widget.oldTransaction.date,
            onSubmit: (DateTime date, double amount, String note, int recurringMonths, RecurrenceType recurrenceType) {
              _handleSubmit(date, fromAccount, toAccount, amount, currency, note);
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

  void _handleSubmit(DateTime date, Account fromAccount, Account toAccount, double amount, Currency currency, String note) async {
    await TransactionHelper.updateTransfer(widget.oldTransaction,date, fromAccount.id, toAccount.id, amount, currency, note);
    widget.onAddTransactionReload();
  }
}

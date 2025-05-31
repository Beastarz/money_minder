import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_button.dart';
import 'package:money_minder/components/input_form_sheet/top_card.dart';
import 'package:money_minder/components/transaction/transaction_helper.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../models/category.dart';
import '../../style/app_size.dart';
import 'input_form_helper.dart';
import 'input_form_sheet.dart';
import 'input_keyboard.dart';

class ExpenseSheet extends StatefulWidget {
  const ExpenseSheet({super.key, required this.mainCurrency, required this.prop, required this.onAddTransactionReload });

  final Currency mainCurrency;
  final CategoryButtonProps prop;
  final void Function() onAddTransactionReload;
  @override
  State<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<ExpenseSheet> {
  Account? fromAccount;
  late Category toCategory;
  late Currency currency;

  @override
  void initState() {
    super.initState();
    _fetchMainAccount();
    toCategory = Category(
        id: widget.prop.id,
        label: widget.prop.label,
        position: widget.prop.position,
        icon: widget.prop.icon,
        color: widget.prop.color,
        isExpense: widget.prop.isExpense
    );
    currency = widget.mainCurrency;
  }

  Future<void> _fetchMainAccount() async {
    Account res = await AccountsRepository.instance.getMainAccounts();
    setState(() {
      fromAccount = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isExpense = widget.prop.isExpense;

    // left card on top of the input form
    final TopCard card1 = TopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topLeft: true,
      title: Text(
          "From ${isExpense ? "Account" : "Category"}",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: AppSize.heading3,
          )
      ),
      content: Padding(
        padding: EdgeInsets.only(
          left: AppSize.smallPadding,
          right: AppSize.smallPadding,
          bottom: AppSize.smallPadding,
        ),
        child: Text(
            isExpense
                ? fromAccount == null ? '' : fromAccount!.name
                : toCategory.label,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: AppSize.heading1 * 1.15,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            )
        ),
      ),
      backgroundColor: isExpense ? Colors.blue : toCategory.color,
      icon: isExpense ? Icon(Icons.credit_card) : toCategory.icon,
      onPressed: () {},
    );

    // right card on top of the input form
    final TopCard card2 = TopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topRight: true,
      title: Text(
          "To ${isExpense ? "Category" : "Account"}",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: AppSize.heading3,
          )
      ),
      content: Padding(
        padding: EdgeInsets.only(
          left: AppSize.smallPadding,
          right: AppSize.smallPadding,
          bottom: AppSize.smallPadding,
        ),
        child: Text(
            isExpense
                ? toCategory.label
                : fromAccount == null ? '' : fromAccount!.name ,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: AppSize.heading1 * 1.15,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            )
        ),
      ),
      backgroundColor: isExpense ? toCategory.color : Colors.blue,
      icon: isExpense ? toCategory.icon : Icon(Icons.credit_card),
      onPressed: () {},
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
          onSubmit: (DateTime date, double amount, String note) {
            _handleSubmit(date, fromAccount!, toCategory, amount, currency, note);
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
              children: [card1, card2]
          ),
        )
    );
  }

  void _handleSubmit(DateTime date, Account fromAccount, Category toCategory, double amount, Currency currency, String note) {
    TransactionHelper.proceedExpense(date, fromAccount, toCategory, amount, currency, note);
    widget.onAddTransactionReload();
  }
}

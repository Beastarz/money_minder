import 'package:flutter/material.dart';
import 'package:money_minder/components/budget_page/budget_helper.dart';
import 'package:money_minder/models/recurrence.dart';

import '../../models/currency.dart';
import '../../repositories/budget_repositories.dart';
import '../../style/app_size.dart';
import '../categories_page/category_button.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/input_keyboard.dart';
import 'budget_tile.dart';
import 'budget_top_card.dart';

class AddBudgetSheet extends StatelessWidget {

  final CategoryProp prop;
  final Currency mainCurrency;
  final DateTime startDate;
  final bool disabledDelete;
  final void Function() onBudgetReload;

  const AddBudgetSheet({
    super.key,
    required this.prop,
    required this.mainCurrency,
    required this.startDate,
    required this.disabledDelete,
    required this.onBudgetReload,
  });

  void _handleSubmit(double amount, int recurringMonths) {
    int month = startDate.month;
    int year = startDate.year;
    for (int i = 0; i < recurringMonths; i++) {
      BudgetHelper.addBudget(DateTime(year, month), amount, prop.id);
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
    }
    onBudgetReload();
  }

  void onDelete() {
    BudgetRepositories.instance.deleteBudget(startDate.month, startDate.year, prop.id);
    onBudgetReload();
  }

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    final double titleSize = (isSmallScreen ? AppSize.heading3 : AppSize.heading1) * 1.5;

    return InputFormSheet(
      // Define the button layout as seen in the image
      inputForm: InputKeyboard(
        buttonProps: InputFormHelper.convertToCalButProps([
          '÷', '7', '8', '9', 'C',
          'x', '4', '5', '6', '<',
          '-', '1', '2', '3', 'budget',
          '+', '\$', '0', '.',
        ], {
          '<': Icons.backspace_outlined,
          'budget': Icons.scale_outlined,
          '✓': Icons.check,
        }
        ),
        showNotes: false,
        defaultValue: prop.budget,
        mainCurrency: mainCurrency,
        onSubmit: (DateTime date, double amount, String note, int recurringMonths, RecurrenceType recurrenceType) {
          Navigator.pop(context);
          _handleSubmit(amount, recurringMonths);
        },
        categoryId: prop.id,
        expenseAsBudget: prop.actualAmount,
        defaultDate: DateTime(startDate.year, startDate.month),
        onCurrencyUpdate: (Currency currency) {

        },
        onDeleteBudget: onDelete,
        disabledBudgetDelete: disabledDelete,
      ),
      topContent: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSize.borderRadius)
          ),
        ),
        child: Row(
            children: [
              BudgetTopCard(
                width: MediaQuery.of(context).size.width,
                topRight: true,
                topLeft: true,
                title: Text(
                  prop.label,
                  style: TextStyle(
                    fontSize: titleSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                content: BudgetTile(
                  prop: prop,
                  mainCurrency: mainCurrency,
                ),
                backgroundColor: prop.color,
                icon: prop.icon,
                isTappable: false,
                // cannot be pressed
                onPressed: null,
              )
            ]
        ),
      ),
      showNotes: false,
    );
  }
}

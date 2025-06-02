import 'package:draggable_home/draggable_home.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/transaction/add_expense_sheet.dart';
import 'package:money_minder/components/categories_page/category_button.dart';
import 'package:money_minder/components/categories_page/center_button.dart';
import 'package:money_minder/components/categories_page/center_pie_chart.dart';

import '../../models/category.dart';
import '../../models/currency.dart';
import '../../style/app_size.dart';
import '../budget_page/budget_tile.dart';
import '../budget_page/budget_top_card.dart';
import '../input_form_sheet/input_form_helper.dart';
import '../input_form_sheet/input_form_sheet.dart';
import '../input_form_sheet/input_keyboard.dart';
import 'categories_sheet.dart';
import 'category_card.dart';

class CategoriesPageContent extends StatefulWidget {

  /// constructor
  final List<List<CategoryProp>> categories;
  final List<double> totalAmounts;
  final Currency mainCurrency;
  final void Function() onAddTransactionReload;

  const CategoriesPageContent({
    super.key,
    required this.categories,
    required this.totalAmounts,
    required this.mainCurrency,
    required this.onAddTransactionReload,
  });

  @override
  State<CategoriesPageContent>createState() => _CategoriesPageContentState();
}

class _CategoriesPageContentState extends State<CategoriesPageContent> {

  /// variables
  // track if currently showing expense or income
  bool _isExpense = true;
  // track which category is chosen
  int _pieTouchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  // the center button will toggle between showing expenses and income each
  // time it is clicked.
  void centerButtonOnPressed() {
    setState(() {
      _isExpense = !_isExpense;
      _pieTouchedIndex = -1;
    });
  }

  // when the categories button is pressed, set _pieTouchedIndex to -1,
  // calculator will be shown to enter new transaction
  void categoriesButtonOnPressed(CategoryProp prop) {
    setState(() {
      _pieTouchedIndex = -1;
    });

    showDialog(
      context: context,
      builder: (context) {
        return CategoryCard(
          prop: prop,
          currency: widget.mainCurrency,
          showTransactionInputForm: showTransactionInputForm,
          showBudgetInputForm: showBudgetInputForm,
        );
      },
    );
  }

  void showTransactionInputForm(CategoryProp prop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return EditExpenseSheet(
            mainCurrency: widget.mainCurrency,
            toCategory: Category(
                id: prop.id,
                label: prop.label,
                position: prop.position,
                icon: prop.icon,
                color: prop.color,
                isExpense: prop.isExpense
            ),
            onAddTransactionReload: widget.onAddTransactionReload,
        );
      }
    );
  }

  void showBudgetInputForm(CategoryProp prop) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    final double titleSize = (isSmallScreen ? AppSize.heading3 : AppSize.heading1) * 1.5;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
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
              mainCurrency: widget.mainCurrency,
              onSubmit: (DateTime date, double amount, String note) {
                Navigator.pop(context);
              },
              onCurrencyUpdate: (Currency currency) {

              },
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
                        mainCurrency: widget.mainCurrency,
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
    );
  }

  // when the pie data is touched for the first time, set _pieTouchedIndex to
  // corresponding index, set it to -1, which is the default value on the second
  // time.
  // when the pie data is set, respective categories button's animation will be
  // triggered. Pie chart will also show the corresponding percentage.
  void pieDataIsTouched(FlTouchEvent e , PieTouchResponse? r) {
    if (r != null && r.touchedSection != null) {
      setState(() {
        if (_pieTouchedIndex == r.touchedSection!.touchedSectionIndex) {
          _pieTouchedIndex = -1;
          return;
        }
        _pieTouchedIndex = r.touchedSection!.touchedSectionIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final List<CategoryProp> categories =
      widget.categories[_isExpense ? 0 : 1];

    return DraggableHome(
      title: Text("Categories"),
      headerWidget: Stack(
        alignment: Alignment.center,
        children: [
          CenterPieChart(
            isExpense: _isExpense,
            pieTouchedIndex: _pieTouchedIndex,
            touchCallback: pieDataIsTouched,
            list: categories,
            totalAmount: widget.totalAmounts[_isExpense ? 0 : 1],
          ),
          CenterButton(
            centerButtonOnPressed: centerButtonOnPressed,
            isExpense: _isExpense,
            totalExpense: widget.totalAmounts[0],
            totalIncome: widget.totalAmounts[1],
            mainCurrency: widget.mainCurrency,
          )
        ],
      ),
      headerExpandedHeight: 0.40,
      body: [
        CategoriesSheet(
          isExpense: _isExpense,
          pieTouchedIndex: _pieTouchedIndex,
          categoriesButtonOnPressed: categoriesButtonOnPressed,
          categories: categories,
          mainCurrency: widget.mainCurrency,
      )]
    );
  }
}

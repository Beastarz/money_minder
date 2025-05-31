import 'package:draggable_home/draggable_home.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/input_form_sheet/input_form_sheet.dart';
import 'package:money_minder/components/input_form_sheet/top_card.dart';
import 'package:money_minder/components/categories_page/categories_button.dart';
import 'package:money_minder/components/categories_page/center_button.dart';
import 'package:money_minder/components/categories_page/center_pie_chart.dart';

import '../../models/currency.dart';
import '../../style/app_size.dart';
import '../input_form_sheet/input_form.dart';
import '../input_form_sheet/input_form_helper.dart';
import 'categories_sheet.dart';

class CategoriesPageContent extends StatefulWidget {

  /// constructor
  final List<List<CategoryButtonProps>> categories;
  final List<double> totalAmounts;
  final Currency mainCurrency;

  const CategoriesPageContent({
    super.key,
    required this.categories,
    required this.totalAmounts,
    required this.mainCurrency,
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
  void categoriesButtonOnPressed(CategoryButtonProps prop) {
    setState(() {
      _pieTouchedIndex = -1;
    });

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    final double titleSize = (isSmallScreen ? AppSize.heading2 : AppSize.heading1) * 1.5;
    final double contentSize = isSmallScreen ? AppSize.paragraph : AppSize.heading3;
    final bool isExpense = prop.isExpense;

    // left card on top of the input form
    final TopCard card1 = TopCard(
      width: MediaQuery.of(context).size.width * 0.5,
      topLeft: true,
      title: Text(
          "From ${isExpense ? "Account" : "Category"}",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: contentSize,
          )
      ),
      content: Padding(
        padding: EdgeInsets.only(
          left: AppSize.smallPadding,
          right: AppSize.smallPadding,
          bottom: AppSize.smallPadding,
        ),
        child: Text(
            isExpense ? "Card" : prop.label,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            )
        ),
      ),
      backgroundColor: isExpense ? Colors.blue : prop.color,
      icon: isExpense ? Icon(Icons.credit_card) : prop.icon,
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
            fontSize: contentSize,
          )
      ),
      content: Padding(
        padding: EdgeInsets.only(
          left: AppSize.smallPadding,
          right: AppSize.smallPadding,
          bottom: AppSize.smallPadding,
        ),
        child: Text(
            isExpense ? prop.label : "Card",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            )
        ),
      ),
      backgroundColor: isExpense ? prop.color : Colors.blue,
      icon: isExpense ? prop.icon : Icon(Icons.credit_card),
      onPressed: () {},
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return InputFormSheet(
          // Define the button layout as seen in the image
          inputForm: InputForm(
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
            mainCurrency: widget.mainCurrency,
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

    final List<CategoryButtonProps> categories =
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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/calculator_sheet/calculator_sheet.dart';
import 'package:money_minder/components/calculator_sheet/top_card.dart';
import 'package:money_minder/components/categories_page/categories_button.dart';
import 'package:money_minder/components/categories_page/center_button.dart';
import 'package:money_minder/components/categories_page/center_pie_chart.dart';

import '../../style/app_size.dart';
import '../calculator_sheet/calculator.dart';
import '../calculator_sheet/calculator_helper.dart';
import 'categories_page_helper.dart';
import 'categories_sheet.dart';

class CategoriesPageContent extends StatefulWidget {
  const CategoriesPageContent({super.key});

  @override
  _CategoriesPageContentState createState() => _CategoriesPageContentState();
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
  void categoriesButtonOnPressed(int index) {
    setState(() {
      _pieTouchedIndex = -1;
    });
    CategoriesButtonProps props =
        CategoriesPageHelper.getCategoriesList(_isExpense)[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {

        final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
        double titleSize = (isSmallScreen ? AppSize.heading2 : AppSize.heading1) * 1.5;
        double contentSize = isSmallScreen ? AppSize.paragraph : AppSize.heading3;
        return CalculatorSheet(
          // Define the button layout as seen in the image
          calculator: Calculator(
            buttonProps: CalculatorHelper.convertToCalButProps([
              '÷', '7', '8', '9', 'C',
              'x', '4', '5', '6', '<',
              '-', '1', '2', '3', 'calendar',
              '+', '\$', '0', '.',
            ], {
              '<': Icons.backspace_outlined,
              'calendar': Icons.calendar_month,
              '✓': Icons.check,
            }
          )),
          topContent: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSize.borderRadius)
              ),
            ),
            child: Row(
              children:[
                TopCard(
                  width: MediaQuery.of(context).size.width * 0.5,
                  topLeft: true,
                  title: Text(
                    "From Account",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: contentSize,
                    )
                  ),
                  content: Text(
                    "Card",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    )
                  ),
                  backgroundColor: Colors.blue,
                  iconPath: "lib/assets/icons/card.svg",
                  onPressed: () {},
                ),
                TopCard(
                  width: MediaQuery.of(context).size.width * 0.5,
                  topRight: true,
                  title: Text(
                    "To Categories",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: contentSize,
                    )
                  ),
                  content: Text(
                    props.label,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    )
                  ),
                  backgroundColor: props.color,
                  iconPath: props.iconPath,
                  onPressed: () {},
                )
              ]
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
    // final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    return Scaffold(
      // No AppBar here, as you only need the body content
      body: Padding(
        padding: EdgeInsets.all(AppSize.bigPadding),
        child: Column( // Use a Column to arrange items vertically
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.05,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                CenterPieChart(
                    isExpense: _isExpense,
                    pieTouchedIndex: _pieTouchedIndex,
                    touchCallback: pieDataIsTouched,
                ),
                CenterButton(
                  centerButtonOnPressed: centerButtonOnPressed,
                  isExpense: _isExpense,
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.1,
            ), // Center button at the top
            CategoriesSheet(
              isExpense: _isExpense,
              pieTouchedIndex: _pieTouchedIndex,
              categoriesButtonOnPressed: categoriesButtonOnPressed,
            ),
          ],
        ),
      ),
      // No BottomNavigationBar here
    );
  }
}

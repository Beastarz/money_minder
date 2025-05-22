import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/center_button.dart';
import 'package:money_minder/components/categories_page/center_pie_chart.dart';

import '../../style/app_size.dart';
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
            ),
          ],
        ),
      ),
      // No BottomNavigationBar here
    );
  }
}

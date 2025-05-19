import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/center_button.dart';

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

  // the center button will toggle between showing expenses and income each
  // time it is clicked.
  void centerButtonOnPressed() {
    setState(() {
      _isExpense = !_isExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar here, as you only need the body content
      body: Padding(
        padding: EdgeInsets.all(AppSize.bigPadding),
        child: Column( // Use a Column to arrange items vertically
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.05,
            ),
            CenterButton(
                centerButtonOnPressed: centerButtonOnPressed,
                isExpense: _isExpense
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.05,
            ), // Center button at the top
            CategoriesSheet(),
          ],
        ),
      ),
      // No BottomNavigationBar here
    );
  }
}

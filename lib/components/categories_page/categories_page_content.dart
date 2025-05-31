import 'package:draggable_home/draggable_home.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/input_form_sheet/input_form_sheet.dart';
import 'package:money_minder/components/input_form_sheet/top_card.dart';
import 'package:money_minder/components/categories_page/categories_button.dart';
import 'package:money_minder/components/categories_page/center_button.dart';
import 'package:money_minder/components/categories_page/center_pie_chart.dart';

import '../../style/app_size.dart';
import '../input_form_sheet/input_keyboard.dart';
import '../input_form_sheet/input_form_helper.dart';
import 'categories_page_helper.dart';
import 'categories_sheet.dart';

class CategoriesPageContent extends StatefulWidget {
  const CategoriesPageContent({super.key});

  @override
  State<CategoriesPageContent>createState() => _CategoriesPageContentState();
}

class _CategoriesPageContentState extends State<CategoriesPageContent> {

  /// variables
  // track if currently showing expense or income
  bool _isExpense = true;
  // track which category is chosen
  int _pieTouchedIndex = -1;
  // categories button props list
  late Future<List<List<CategoryButtonProps>>> _categoriesFuture;

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {

        final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
        double titleSize = (isSmallScreen ? AppSize.heading2 : AppSize.heading1) * 1.5;
        double contentSize = isSmallScreen ? AppSize.paragraph : AppSize.heading3;
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
          )),
          topContent: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSize.borderRadius)
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:[
                TopCard(
                  topLeft: true,
                  header: "From Account",
                  title: "Card",
                  backgroundColor: Colors.blue,
                  icon: Icon(Icons.credit_card),
                  onPressed: () {},
                ),
                TopCard(
                  topRight: true,
                  header: "To Categories",
                  title: prop.label,
                  backgroundColor: prop.color,
                  icon: prop.icon,
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
  void initState() {
    super.initState();
    // Initialize the database and then fetch categories
    _categoriesFuture = CategoriesPageHelper.getCategoriesList();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<List<CategoryButtonProps>>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Data is still loading, show a progress indicator
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // An error occurred
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // Data has been successfully loaded!
          // categories[0] is expenseCategories
          // categories[1] is incomeCategories
           final List<List<CategoryButtonProps>> categories = snapshot.data!;

          if (categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          return DraggableHome(
            title: Text("Categories"),
            headerWidget: Stack(
              alignment: Alignment.center,
              children: [
                CenterPieChart(
                  isExpense: _isExpense,
                  pieTouchedIndex: _pieTouchedIndex,
                  touchCallback: pieDataIsTouched,
                  list: categories[_isExpense ? 0 : 1],
                  totalAmount: CategoriesPageHelper.getTotalAmount(
                      categories[_isExpense ? 0 : 1]
                  ),
                ),
                CenterButton(
                  centerButtonOnPressed: centerButtonOnPressed,
                  isExpense: _isExpense,
                  totalExpense: CategoriesPageHelper
                      .getTotalAmount(categories[0]),
                  totalIncome: CategoriesPageHelper
                      .getTotalAmount(categories[1]),
                )
              ],
            ),
            headerExpandedHeight: 0.35,
            body: [
              CategoriesSheet(
                isExpense: _isExpense,
                pieTouchedIndex: _pieTouchedIndex,
                categoriesButtonOnPressed: categoriesButtonOnPressed,
                categories: categories[_isExpense ? 0 : 1],
            )]
          );

    //       return Scaffold(
    //         // No AppBar here, as you only need the body content
    //         body: Padding(
    //           padding: EdgeInsets.all(AppSize.bigPadding),
    //           child: Column( // Use a Column to arrange items vertically
    //             children: [
    //               SizedBox(
    //                 height: MediaQuery
    //                     .of(context)
    //                     .size
    //                     .width * 0.05,
    //               ),
    //               Stack(
    //                 alignment: Alignment.center,
    //                 children: [
    //                   CenterPieChart(
    //                     isExpense: _isExpense,
    //                     pieTouchedIndex: _pieTouchedIndex,
    //                     touchCallback: pieDataIsTouched,
    //                     list: categories[_isExpense ? 0 : 1],
    //                     totalAmount: CategoriesPageHelper.getTotalAmount(
    //                         categories[_isExpense ? 0 : 1]
    //                     ),
    //                   ),
    //                   CenterButton(
    //                     centerButtonOnPressed: centerButtonOnPressed,
    //                     isExpense: _isExpense,
    //                     totalExpense: CategoriesPageHelper
    //                         .getTotalAmount(categories[0]),
    //                     totalIncome: CategoriesPageHelper
    //                         .getTotalAmount(categories[1]),
    //                   )
    //                 ],
    //               ),
    //               SizedBox(
    //                 height: MediaQuery
    //                     .of(context)
    //                     .size
    //                     .width * 0.1,
    //               ), // Center button at the top
    //               CategoriesSheet(
    //                 isExpense: _isExpense,
    //                 pieTouchedIndex: _pieTouchedIndex,
    //                 categoriesButtonOnPressed: categoriesButtonOnPressed,
    //                 categories: categories[_isExpense ? 0 : 1],
    //               ),
    //             ],
    //           ),
    //         ),
    //         // No BottomNavigationBar here
    //       );
        } else {
          return const Center(child: Text("No data available"));
        }
      }
    );
  }
}

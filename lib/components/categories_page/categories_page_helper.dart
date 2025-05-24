import 'package:flutter_svg/svg.dart';

import '../../style/app_color.dart';
import 'categories_button.dart';
import 'package:flutter/material.dart';

class CategoriesPageHelper {

  static final List<CategoriesButtonProps> expenseList = [
    CategoriesButtonProps(
      index: 0,
      label: 'Groceries',
      iconPath: 'lib/assets/icons/groceries.svg',
      color: Colors.blueAccent,
      actualAmount: 99.00,
      expectedAmount: 20000.00,
    ),
    CategoriesButtonProps(
      index: 1,
      label: 'Leisure',
      iconPath: 'lib/assets/icons/ticket.svg',
      color: Colors.redAccent,
      actualAmount: 100.00,
      expectedAmount: 200.00,
    ),
    CategoriesButtonProps(
      index: 2,
      label: 'Health',
      iconPath: 'lib/assets/icons/health.svg',
      color: Colors.greenAccent,
      actualAmount: 100.00,
      expectedAmount: 200.00,
    ),
    CategoriesButtonProps(
      index: 3,
      label: 'Transport',
      iconPath: 'lib/assets/icons/bus.svg',
      color: Colors.grey,
      actualAmount: 200,
      expectedAmount: 0,
    ),
    CategoriesButtonProps(
      index: 4,
      label: 'Restaurant',
      iconPath: 'lib/assets/icons/restaurant.svg',
      color: Colors.orangeAccent,
      actualAmount: 130.00,
      expectedAmount: 240.00,
    ),
    CategoriesButtonProps(
      index: 5,
      label: 'Gift',
      iconPath: 'lib/assets/icons/gift.svg',
      color: Colors.pinkAccent,
      actualAmount: 30.00,
      expectedAmount: 50.00,
    ),
    CategoriesButtonProps(
      index: 6,
      label: 'Family',
      iconPath: 'lib/assets/icons/home.svg',
      color: Colors.deepPurpleAccent,
      actualAmount: 20.00,
      expectedAmount: 130.00,
    ),
    CategoriesButtonProps(
      index: 7,
      label: 'Shopping',
      iconPath: 'lib/assets/icons/shopping.svg',
      color: Colors.brown,
      actualAmount: 50.00,
      expectedAmount: 350.00,
    ),
    CategoriesButtonProps(
      index: 8,
      label: 'Sport',
      iconPath: 'lib/assets/icons/running.svg',
      color: Colors.yellow,
      actualAmount: 50.00,
      expectedAmount: 350.00,
    ),
    AddCategoriesButtonProps(9),
  ];

  static final List<CategoriesButtonProps> incomeList = [
    CategoriesButtonProps(
      index: 0,
      label: 'Income',
      iconPath: 'lib/assets/icons/income.svg',
      color: Colors.blueAccent,
      actualAmount: 2000,
      expectedAmount: 2000,
    ),
    AddCategoriesButtonProps(1),
  ];

  // get the total amount of the categories
  static double getTotalAmount(List<CategoriesButtonProps> list) {
    double total = 0;
    for (CategoriesButtonProps item in list) {
      total += item.actualAmount;
    }
    return total;
  }

  static Widget generateButtonIcon(String path) {
    return SvgPicture.asset(
      path,
      colorFilter: ColorFilter.mode(
        AppColor.lightIcon,
        BlendMode.srcIn,
      ),
      width: 30,
      height: 30,
    );
  }

  // generate data for the category icons and labels (default)
  static List<CategoriesButtonProps> getCategoriesList(bool isExpense) {
    return isExpense
        ? expenseList
        : incomeList;
  }
}

import 'package:flutter_svg/svg.dart';

import '../../style/app_color.dart';
import 'categories_button.dart';
import 'package:flutter/material.dart';

class CategoriesPageHelper {

  static final List<CategoriesButtonProps> expenseList = [
    CategoriesButtonProps(
      label: 'Groceries',
      iconPath: 'lib/assets/icons/groceries.svg',
      color: Colors.blueAccent,
      actualAmount: 99.00,
      expectedAmount: 20000.00,
    ),
    CategoriesButtonProps(
      label: 'Leisure',
      iconPath: 'lib/assets/icons/ticket.svg',
      color: Colors.redAccent,
      actualAmount: 100.00,
      expectedAmount: 200.00,
    ),
    CategoriesButtonProps(
      label: 'Health',
      iconPath: 'lib/assets/icons/health.svg',
      color: Colors.greenAccent,
      actualAmount: 100.00,
      expectedAmount: 200.00,
    ),
    CategoriesButtonProps(
      label: 'Transport',
      iconPath: 'lib/assets/icons/bus.svg',
      color: Colors.grey,
      actualAmount: 20,
      expectedAmount: 0,
    ),
    CategoriesButtonProps(
      label: 'Restaurant',
      iconPath: 'lib/assets/icons/restaurant.svg',
      color: Colors.orangeAccent,
      actualAmount: 130.00,
      expectedAmount: 240.00,
    ),
    CategoriesButtonProps(
      label: 'Gift',
      iconPath: 'lib/assets/icons/gift.svg',
      color: Colors.pinkAccent,
      actualAmount: 30.00,
      expectedAmount: 50.00,
    ),
    CategoriesButtonProps(
      label: 'Family',
      iconPath: 'lib/assets/icons/home.svg',
      color: Colors.deepPurpleAccent,
      actualAmount: 20.00,
      expectedAmount: 130.00,
    ),
    CategoriesButtonProps(
      label: 'Shopping',
      iconPath: 'lib/assets/icons/shopping.svg',
      color: Colors.brown,
      actualAmount: 50.00,
      expectedAmount: 350.00,
    ),
    CategoriesButtonProps(
      label: 'Sport',
      iconPath: 'lib/assets/icons/running.svg',
      color: Colors.yellow,
      actualAmount: 50.00,
      expectedAmount: 350.00,
    ),
    AddCategoriesButtonProps(),
  ];

  static final List<CategoriesButtonProps> incomeList = [
    CategoriesButtonProps(
      label: 'Income',
      iconPath: 'lib/assets/icons/income.svg',
      color: Colors.blueAccent,
      actualAmount: 2000,
      expectedAmount: 2000,
    ),
    AddCategoriesButtonProps(),
  ];

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

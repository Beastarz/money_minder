import 'package:money_minder/repositories/categories_repositories.dart';
import 'package:money_minder/models/category.dart';

import 'categories_button.dart';

class CategoriesPageHelper {

  // get the total amount of the categories
  static double getTotalAmount(List<CategoryButtonProps> list) {
    double total = 0;
    for (CategoryButtonProps item in list) {
      total += item.actualAmount;
    }
    return total;
  }

  // convert Category to CategoryButtonProps
  static List<CategoryButtonProps> convertToCatButProps(List<Category> list) {
    List<CategoryButtonProps> result = [];
    for (Category cat in list) {
      result.add(CategoryButtonProps(
          index: cat.position,
          label: cat.label,
          icon: cat.icon,
          color: cat.color,
          actualAmount: 100,
          expectedAmount: cat.expectedAmount,
          isExpense: cat.isExpense,
      ));
    }
    return result;
  }

  // generate data for the category icons and labels (combined)
  static Future<List<List<CategoryButtonProps>>> getCategoriesList() async {
    List<CategoryButtonProps> expenseCategories =
      await getCategoriesListByType(true);
    List<CategoryButtonProps> incomeCategories =
      await getCategoriesListByType(false);
    expenseCategories.add(AddCategoriesButtonProps(expenseCategories.length));
    incomeCategories.add(AddCategoriesButtonProps(incomeCategories.length));
    return [expenseCategories, incomeCategories];
  }

  // generate data for the category icons and labels (expense or income)
  static Future<List<CategoryButtonProps>> getCategoriesListByType(
      bool isExpense) async {
    List<Category> categories =
      await CategoriesRepositories.instance.getCategoriesByType(isExpense);
    return convertToCatButProps(categories);
  }
}
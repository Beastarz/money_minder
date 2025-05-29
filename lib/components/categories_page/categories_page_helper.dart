import 'package:money_minder/models/category.dart';

import '../../models/transaction.dart';
import 'categories_button.dart';

class CategoriesPageHelper {

  // convert Category to CategoryButtonProps
  static List<CategoryButtonProps> convertToCatButProps(
      List<Category> categories,
      List<Transaction> transactions,
      List<double> totalAmounts,
      bool isExpense
      ) {

    // calculate the total amount of each category
    List<double> amounts = [];
    for (int i = 0; i < categories.length; i++) {
      amounts.add(0);
    }
    String targetType = isExpense ? 'expense' : 'income';
    for (Transaction t in transactions) {
      if (t.type == targetType) {
        int catIndex = t.toCategory!.position;
        amounts[catIndex] += t.amount;
        totalAmounts[isExpense ? 0 : 1] += t.amount;
      }
    }

    // sort the categories according to their position
    categories.sort((a, b) => a.position.compareTo(b.position));

    // convert the categories to CategoryButtonProps
    List<CategoryButtonProps> result = [];
    for (int i = 0; i < categories.length; i++) {
      Category category = categories[i];
      result.add(
        CategoryButtonProps(
            position: category.position,
            label: category.label,
            icon: category.icon,
            color: category.color,
            actualAmount: amounts[category.position],
            expectedAmount: category.expectedAmount,
            isExpense: category.isExpense)
      );
    }
    return result;
  }
}
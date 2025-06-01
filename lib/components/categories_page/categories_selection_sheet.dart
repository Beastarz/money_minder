import 'package:flutter/material.dart';
import 'package:money_minder/models/category.dart';
import 'package:money_minder/utils/main_icon.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class CategoriesSelectionSheet extends StatelessWidget {
  const CategoriesSelectionSheet({super.key, required this.expenses, required this.incomes, required this.onSelect});

  final List<Category> expenses;
  final List<Category> incomes;
  final void Function(Category) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppSize.smallPadding),
                      child: Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: AppSize.heading1,
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 0),
                child: Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: AppSize.heading2,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText,
                  ),
                ),
              ),
              Divider(
                color: Colors.grey[700],
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                children: expenses.map((expense) => Column(
                  children: [
                    IconButton(
                      icon: MainIcon(icon: expense.icon, color: expense.color),
                      onPressed: () {
                        onSelect(expense);
                        Navigator.pop(context);
                      },
                    ),
                    Text(expense.label, style: TextStyle(fontSize: 12),)
                  ],
                )).toList(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 8, 0),
                child: Text(
                  'Incomes',
                  style: TextStyle(
                    fontSize: AppSize.heading2,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText,
                  ),
                ),
              ),
              Divider(
                color: Colors.grey[700],
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                children: incomes.map((income) => Center(
                  child: Column(
                      children: [
                        IconButton(
                          icon: MainIcon(icon: income.icon, color: income.color,),
                          onPressed: () {
                            onSelect(income);
                            Navigator.pop(context);
                          },
                        ),
                        Text(income.label, style: TextStyle(fontSize: 12),)
                      ]
                  ),
                )).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

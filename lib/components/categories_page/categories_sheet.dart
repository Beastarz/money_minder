import 'package:flutter/material.dart';

import 'categories_button.dart';

class CategoriesSheet extends StatelessWidget {
  CategoriesSheet({super.key});

  // Data for the category icons and labels (default)
  final List<CategoriesButtonProps> _categories = [
    CategoriesButtonProps(
      label: 'Groceries',
      iconPath: 'lib/assets/icons/groceries.svg',
      color: Colors.blueAccent,
      expense: 9999.00,
      budget: 20000.00,
    ),
    CategoriesButtonProps(
      label: 'Leisure',
      iconPath: 'lib/assets/icons/ticket.svg',
      color: Colors.redAccent,
      expense: 100.00,
      budget: 200.00,
    ),
    CategoriesButtonProps(
      label: 'Health',
      iconPath: 'lib/assets/icons/health.svg',
      color: Colors.greenAccent,
      expense: 100.00,
      budget: 200.00,
    ),
    CategoriesButtonProps(
      label: 'Transport',
      iconPath: 'lib/assets/icons/bus.svg',
      color: Colors.grey,
      expense: 20,
      budget: 0,
    ),
    CategoriesButtonProps(
      label: 'Restaurant',
      iconPath: 'lib/assets/icons/restaurant.svg',
      color: Colors.orangeAccent,
      expense: 130.00,
      budget: 240.00,
    ),CategoriesButtonProps(
      label: 'Gift',
      iconPath: 'lib/assets/icons/gift.svg',
      color: Colors.pinkAccent,
      expense: 30.00,
      budget: 50.00,
    ),CategoriesButtonProps(
      label: 'Family',
      iconPath: 'lib/assets/icons/home.svg',
      color: Colors.deepPurpleAccent,
      expense: 20.00,
      budget: 130.00,
    ),CategoriesButtonProps(
      label: 'Shopping',
      iconPath: 'lib/assets/icons/shopping.svg',
      color: Colors.brown,
      expense: 50.00,
      budget: 350.00,
    ),
    CategoriesButtonProps(
      label: 'Sport',
      iconPath: 'lib/assets/icons/running.svg',
      color: Colors.yellow,
      expense: 50.00,
      budget: 350.00,
    ),
    AddCategoriesButtonProps(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    return Expanded( // Use Expanded to make the grid take up remaining space
      child: SingleChildScrollView(
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.8,
            crossAxisCount: isSmallScreen ? 3 : 4,
            crossAxisSpacing: 4.0,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return CategoriesButton(
              props: _categories[index],
            );
          },
        ),
      ),
    );
  }
}
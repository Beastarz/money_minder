import 'package:flutter/material.dart';

import 'categories_button.dart';

class CategoriesSheet extends StatelessWidget {
  CategoriesSheet({super.key});

  // Data for the category icons and labels (default)
  final List<Map<String, String>> _categories = [
    {'label': 'Groceries', 'icon': 'lib/assets/icons/groceries.svg'}, // Use svgs
    {'label': 'Leisure', 'icon': 'lib/assets/icons/ticket.svg'},
    {'label': 'Health', 'icon': 'lib/assets/icons/health.svg'},
    {'label': 'Transport', 'icon': 'lib/assets/icons/bus.svg'},
    {'label': 'Restaurant', 'icon': 'lib/assets/icons/restaurant.svg'},
    {'label': 'Gifts', 'icon': 'lib/assets/icons/gift.svg'},
    {'label': 'Family', 'icon': 'lib/assets/icons/home.svg'},
    {'label': 'Shopping', 'icon': 'lib/assets/icons/shopping.svg'},
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
            crossAxisCount: isSmallScreen ? 3 : 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 20.0,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return CategoriesButton(
                label: _categories[index]['label'] ?? 'Unknown',
                iconPath: _categories[index]['icon'] ?? '',
                categoriesButtonOnPressed: () {
                  print('Clicked on ${_categories[index]['label']}');
                }
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';

import '../../components/tutorial/tutorial_text_box.dart';

class CategoryTutorial extends StatelessWidget {
  const CategoryTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: MediaQuery.of(context).size.width * 0.1),
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Categories Page', style: TextStyle(fontSize: 24),)),
                TutorialImage(imagePath: 'assets/tutorial_pictures/category_page.jpg', title: "Categories Page"),
                TutorialTextBox(prefix: '1.', body: 'Period bar - Navigate through different period zones by clicking left and right button or change the period by tapping on the center button.'),
                TutorialTextBox(prefix: '2.', body: 'Category pie chart - Tap to switch between expense and income mode.'),
                TutorialTextBox(prefix: '3.', body: 'Category - Tap to log transactions on this category.'),
                TutorialTextBox(prefix: '4.', body: 'Add new category button - Tap to navigate to add category page.'),
                TutorialTextBox(prefix: '5.', body: 'Mode switch - Switch between view category details mode and transaction logging shortcut mode.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/category_detail.jpg', title: 'Category Details Card'),
                TutorialTextBox(prefix: '1.', body: 'Budget Section - Tap to add or edit budget.'),
                TutorialTextBox(prefix: '2.', body: 'Add transaction button - Tap to add a new transaction to this category.'),
                TutorialTextBox(prefix: '3.', body: 'View transaction button - Tap to view transactions filtered by this category.'),
                TutorialTextBox(prefix: '4.', body: 'Edit category button - Tap to edit this category.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/add_category.jpg', title: 'Add Category Sheet'),
                TutorialTextBox(prefix: '1.', body: 'Category name field - Input your category name here.'),
                TutorialTextBox(prefix: '2.', body: 'Icon tab - Select an icon for your category.'),
                TutorialTextBox(prefix: '3.', body: 'Color tab - Select a color for your category.'),
                TutorialTextBox(prefix: '4.', body: 'Add category button - Create your new category.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/edit_category.png', title: 'Edit Category Sheet'),
                TutorialTextBox(prefix: '1.', body: 'Delete category button - Tap to delete this category.'),
              ],
            ),
          ),
        )
    );
  }
}

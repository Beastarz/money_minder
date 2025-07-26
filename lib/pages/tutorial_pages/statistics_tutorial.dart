import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';
import 'package:money_minder/components/tutorial/tutorial_text_box.dart';

class StatisticsTutorial extends StatelessWidget {
  const StatisticsTutorial({super.key});

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
                Center(child: Text('Statistics Page', style: TextStyle(fontSize: 24),)),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/statistic_page.jpg', title: 'Statistics Page'),
                TutorialTextBox(prefix: '1.', body: 'Period Bar - Tap the left and right arrows to view statistics in different periods. Tap the calender button to change period settings.'),
                TutorialTextBox(prefix: '2.', body: 'Expense/Income Total Bar - Tap to switch between expenses and incomes.'),
                TutorialTextBox(prefix: '3.', body: 'Statistics Charts - Tap to have a bigger view on the charts.'),
                TutorialTextBox(prefix: '4.', body: 'Sort By - Tap to change the sort by settings of the statistics.'),
                TutorialTextBox(prefix: '5.', body: 'Sorting Order - Tap to change the sorting order of the statistics.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/statistic_cat_detail.jpg', title: 'Statistics Category Card'),
                TutorialTextBox(prefix: '1.', body: 'Budget Section - Tap to add or edit budget.'),
                TutorialTextBox(prefix: '2.', body: 'Add Transaction Button - Tap to add a new transaction to this category.'),
                TutorialTextBox(prefix: '3.', body: 'View Transaction Button - Tap to view transactions filtered by this category.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

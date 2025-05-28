import 'package:flutter/material.dart';
import 'package:money_minder/components/statistics_page/statistic_sheet.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class StatisticsPageContent extends StatefulWidget {
  const StatisticsPageContent({super.key});

  @override
  State<StatisticsPageContent> createState() => _StatisticsPageContentState();
}

class _StatisticsPageContentState extends State<StatisticsPageContent> {

  bool _isExpense = true;

  // switch between expense sheet and income sheet
  void switchContent(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
    });
  }

  // Function to lighten a color by mixing it with white
  Color _lightenColor(Color color, double factor) {
    // factor: 0.0 means no white, 1.0 means pure white
    return Color.lerp(color, Colors.white, factor)!;
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSize.bigPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // button to choose whether to display expenses or savings
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    switchContent(true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(AppSize.smallPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(AppSize.borderRadius),
                        right: Radius.circular(AppSize.borderRadius * 0.5),
                      ),
                    ),
                    backgroundColor: _isExpense
                      ? Colors.redAccent
                      : _lightenColor(Colors.redAccent, 0.9),
                  ),
                  child: Column(
                    spacing: 5,
                    children:[
                      Text(
                        "Expenses",
                        style: TextStyle(
                          fontSize: AppSize.heading3,
                          color: _isExpense
                            ? AppColor.lightText
                            : AppColor.darkText
                        ),
                      ),
                      Text(
                        "\$100",
                        style: TextStyle(
                          fontSize: AppSize.heading2,
                          color: _isExpense
                            ? AppColor.lightText
                            : Colors.redAccent
                        ),
                      )
                    ]
                  )
                )
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    switchContent(false);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(AppSize.smallPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(AppSize.borderRadius * 0.5),
                        right: Radius.circular(AppSize.borderRadius),
                      ),
                    ),
                    backgroundColor: _isExpense
                        ? _lightenColor(Colors.greenAccent, 0.9)
                        : Colors.greenAccent,
                  ),
                  child: Column(
                    spacing: 5,
                    children:[
                      Text(
                        "Income",
                        style: TextStyle(
                          fontSize: AppSize.heading3,
                          color: _isExpense
                            ? AppColor.darkText
                            : AppColor.lightText
                        ),
                      ),
                      Text(
                        "\$100",
                        style: TextStyle(
                          fontSize: AppSize.heading2,
                          color: _isExpense
                            ? Colors.greenAccent
                            : AppColor.lightText
                        ),
                      )
                    ]
                  )
                )
              ),
            ],
          ),

          // budget sheet
          StatisticsSheet(
            isExpense: _isExpense,
          ),
        ],
      )
    );

    // return SingleChildScrollView( // Use SingleChildScrollView if content might exceed screen height
    //   child: Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         // --- Expenses Section ---
    //         _buildSectionHeader(context, 'Expenses', spentAmount: '\$0'),
    //         const SizedBox(height: 10),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceAround,
    //           children: [
    //             _buildCategoryItem(context, 'Restaurant', Icons.restaurant),
    //             _buildCategoryItem(context, 'Gifts', Icons.card_giftcard),
    //             _buildCategoryItem(context, 'Family', Icons.family_restroom),
    //             _buildCategoryItem(context, 'More...', Icons.more_horiz),
    //           ],
    //         ),
    //         const SizedBox(height: 20),
    //
    //         // --- Savings Section ---
    //         _buildSectionHeader(context, 'Savings', depositedAmount: '\$0', budgetedAmount: '\$0'),
    //         const SizedBox(height: 20),
    //
    //         // --- Income Section ---
    //         _buildSectionHeader(context, 'Income', receivedAmount: '\$0', budgetedAmount: '\$0'),
    //         const SizedBox(height: 10),
    //         Row(
    //           children: [
    //             _buildCategoryItem(context, 'Salary', Icons.attach_money),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {String? spentAmount, String? depositedAmount, String? receivedAmount, String? budgetedAmount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (spentAmount != null)
                  Text('spent $spentAmount', style: Theme.of(context).textTheme.bodyLarge),
                if (depositedAmount != null)
                  Text('deposited $depositedAmount', style: Theme.of(context).textTheme.bodyLarge),
                if (receivedAmount != null)
                  Text('received $receivedAmount', style: Theme.of(context).textTheme.bodyLarge),
                if (budgetedAmount != null)
                  Text('budgeted $budgetedAmount', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ],
        ),
        const Divider(height: 20, thickness: 1), // Separator line
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, String categoryName, IconData icon) {
    return Expanded( // Use Expanded to give equal width to items in a Row
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Example background color
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple), // Example icon color
          ),
          const SizedBox(height: 5),
          Text(categoryName),
          const SizedBox(height: 5),
          Text('\$0', style: Theme.of(context).textTheme.bodyMedium), // Example amount
        ],
      ),
    );
  }
}
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
                              right: Radius.circular(
                                  AppSize.borderRadius * 0.5),
                            ),
                          ),
                          backgroundColor: _isExpense
                              ? Colors.redAccent
                              : _lightenColor(Colors.redAccent, 0.9),
                        ),
                        child: Column(
                            spacing: 5,
                            children: [
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
                            children: [
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
  }
}
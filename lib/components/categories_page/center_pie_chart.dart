import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../style/app_size.dart';
import 'categories_button.dart';
import 'categories_page_helper.dart';

class CenterPieChart extends StatelessWidget {

  /// variable
  // track if currently showing expense or income
  final bool isExpense;
  final int pieTouchedIndex;
  final void Function(FlTouchEvent, PieTouchResponse?)? touchCallback;

  const CenterPieChart({
    super.key,
    required this.isExpense,
    required this.pieTouchedIndex,
    required this.touchCallback,
  });

  @override
  Widget build(BuildContext context) {

    // generate list of categories
    List<CategoriesButtonProps> list =
      CategoriesPageHelper.getCategoriesList(isExpense);
    double totalAmount = CategoriesPageHelper.getTotalAmount(list);

    // generate PieData for the pie chart
    List<PieChartSectionData> pieData =
      list.asMap()
        .entries
        .map((entry) {
            final index = entry.key;
            final data = entry.value;
            final isTouched = index == pieTouchedIndex;
            return PieChartSectionData(
              value: data.actualAmount,
              color: data.color,
              showTitle: isTouched,
              title: "${(data.actualAmount / totalAmount * 100)
                  .toStringAsFixed(2)}%",
              titleStyle: TextStyle(
                fontSize: AppSize.paragraph,
              ),
              titlePositionPercentageOffset: 2,
              radius: isTouched ? 25 : 15,
            );
    }).toList();

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 0.5,
        width: MediaQuery.of(context).size.width * 0.5,
        child: PieChart(
          PieChartData(
            sections: pieData,
            pieTouchData: PieTouchData(
              touchCallback: touchCallback,
            ),
          ),
        ),
      )
    );
  }
}

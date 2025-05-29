import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'categories_button.dart';

class CenterPieChart extends StatelessWidget {

  /// variable
  // track if currently showing expense or income
  final bool isExpense;
  final int pieTouchedIndex;
  final void Function(FlTouchEvent, PieTouchResponse?)? touchCallback;
  final List<CategoryButtonProps> list;
  final double totalAmount;

  const CenterPieChart({
    super.key,
    required this.isExpense,
    required this.pieTouchedIndex,
    required this.touchCallback,
    required this.list,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    bool isEmpty = true;
    // generate PieData for the pie chart
    List<PieChartSectionData> pieData =
      list.asMap()
        .entries
        .map((entry) {
            final index = entry.key;
            final data = entry.value;
            final isTouched = index == pieTouchedIndex;
            if (data.actualAmount != 0) {
              isEmpty = false;
            }
            return PieChartSectionData(
              value: data.actualAmount,
              color: data.color,
              showTitle: isTouched,
              title: "${(data.actualAmount / totalAmount * 100)
                  .toStringAsFixed(2)}%",
              titleStyle: TextStyle(
                fontSize: isSmallScreen ? 10 : AppSize.paragraph,
              ),
              titlePositionPercentageOffset: 2,
              radius: isTouched ? (isSmallScreen ? 20 : 25) : 15,
            );
    }).toList();

    // pie chart is empty
    if (isEmpty) {
      pieData.clear();
      pieData.add(
        PieChartSectionData(
          value: 1,
          color: AppColor.tertiary,
          showTitle: false,
          radius: 15,
        )
      );
    }

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.width * (
          isSmallScreen ? 0.4 : 0.5
        ),
        width: MediaQuery.of(context).size.width * (
          isSmallScreen ? 0.4 : 0.5
        ),
        child: PieChart(
          PieChartData(
            sections: pieData,
            pieTouchData: PieTouchData(
              touchCallback: isEmpty ? null : touchCallback,
            ),
          ),
        ),
      )
    );
  }
}

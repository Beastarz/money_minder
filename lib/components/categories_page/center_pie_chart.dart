import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'categories_page_helper.dart';

class CenterPieChart extends StatefulWidget {

  /// variable
  // track if currently showing expense or income
  final bool isExpense;

  const CenterPieChart({
    super.key,
    required this.isExpense,
  });

  @override
  State<CenterPieChart> createState() => _CenterPieChartState();
}

class _CenterPieChartState extends State<CenterPieChart> {

  /// variable
  // indicate which pie chart section is touched
  int pieTouchedIndex = -1;

  @override
  Widget build(BuildContext context) {

    // generate PieData for the pie chart
    List<PieChartSectionData> pieData =
      CategoriesPageHelper.getCategoriesList(widget.isExpense)
        .asMap()
        .entries
        .map((entry) {
            final index = entry.key;
            final data = entry.value;
            final isTouched = index == pieTouchedIndex;
            return PieChartSectionData(
              value: data.actualAmount,
              color: data.color,
              showTitle: false,
              radius: isTouched ? 30 : 20,
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
              touchCallback:
                  (FlTouchEvent e, PieTouchResponse? r) {
                if (r != null && r.touchedSection != null) {
                  setState(() {
                    if (pieTouchedIndex == r.touchedSection!.touchedSectionIndex) {
                      pieTouchedIndex = -1;
                      return;
                    }
                    pieTouchedIndex = r.touchedSection!.touchedSectionIndex;
                  });
                }
              },
            ),
          ),
        ),
      )
    );
  }
}

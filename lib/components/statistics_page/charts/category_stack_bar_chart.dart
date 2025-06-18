import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/category_button.dart';

import '../../../models/currency.dart';
import '../../../models/date_filter.dart';
import '../../../models/transaction.dart';
import '../../../style/app_color.dart';
import '../statistics_helper.dart';

class CategoryStackBarChart extends StatefulWidget {

  final double aspectRatio;
  final bool isExpanded;
  final bool isExpense;
  final Currency currency;
  final List<CategoryProp> catList;
  final List<Transaction> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final DateFilterType type;

  const CategoryStackBarChart({
    super.key,
    required this.aspectRatio,
    required this.isExpanded,
    required this.isExpense,
    required this.currency,
    required this.catList,
    required this.transactions,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  @override
  State<StatefulWidget> createState() => CategoryStackBarChartState();
}

class CategoryStackBarChartState extends State<CategoryStackBarChart> {

  late List<DateTime> dates;
  late List<BarChartRodData> data;
  int touchedGroupIndex = -1;
  List<int> showDateIndex = [];

  void onLoad() {
    setState(() {
      dates = StatisticsHelper.slicePeriod(widget.startDate, widget.endDate,
          widget.isExpanded, widget.type);
      int ranges = widget.endDate.difference(widget.startDate).inDays;
      int days = 1;
      if (ranges > 365 * 3) {
        days = 365;
      } else if (ranges > 180) {
        days = 30;
      } else if (ranges > 90) {
        days = 10;
      } else if (ranges > 31) {
        days = 3;
      }
      data = StatisticsHelper.getStackBarChartDate(
          widget.transactions, dates, days, widget.catList, showDateIndex);
    });
  }

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  void didUpdateWidget(CategoryStackBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    onLoad();
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    Widget text;
    int i = showDateIndex.indexOf(value.toInt());
    if (i != -1) {
      int day = dates[i].day;
      int month = dates[i].month;
      int year = dates[i].year;
      int range = widget.endDate.difference(widget.startDate).inDays + 1;
      text = Text(
        range >= 365
            ? '${StatisticsHelper.months[month - 1]} ${year % 100}'
            : '$day/$month',
        style: style,
        textAlign: TextAlign.center,
      );
    } else {
      text = Text("");
    }

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    return SideTitleWidget(
      meta: meta,
      child: Text(
        meta.formattedValue,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'Stacked ${widget.isExpense ? "Expense" : "Income"} x Period',
            style: TextStyle(
              color: AppColor.darkText,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 5),
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchTooltipData: BarTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipColor: (group) => Colors.white,
                      tooltipMargin: 0,
                      getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                          ) {
                        String text = "";
                        double total = 0;
                        for (int i = 0; i < rod.rodStackItems.length; i++) {
                          double amount = rod.rodStackItems[i].toY - rod.rodStackItems[i].fromY;
                          text += "${widget.currency.toString()} ${amount.toStringAsFixed(2)}\n";
                          total += amount;
                        }
                        text += "= ${widget.currency.toString()} ${total.toStringAsFixed(2)}";
                        return BarTooltipItem(
                          text,
                          textAlign: TextAlign.right,
                          TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rod.color,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (event.isInterestedForInteractions &&
                          response != null &&
                          response.spot != null) {
                        setState(() {
                          touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                        });
                      } else {
                        setState(() {
                          touchedGroupIndex = -1;
                        });
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: bottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppColor.quaternary),
                  ),
                  barGroups: data.indexed.map((d) {
                    return BarChartGroupData(
                      x: d.$1,
                      barRods: [d.$2],
                      showingTooltipIndicators: touchedGroupIndex == d.$1 ? [0] : [],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
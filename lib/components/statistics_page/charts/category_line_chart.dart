import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/models/currency.dart';
import 'package:money_minder/models/date_filter.dart';

import '../../../models/transaction.dart';
import '../../../style/app_color.dart';
import '../../categories_page/category_button.dart';
import '../statistics_helper.dart';

class CategoryLineChart extends StatefulWidget {

  final double aspectRatio;
  final bool isExpanded;
  final bool isExpense;
  final DateTime startDate;
  final DateTime endDate;
  final DateFilterType type;
  final Currency currency;
  final bool showIndividual;
  final void Function() onChangeType;
  final List<CategoryProp> catList;
  final List<Transaction> transactions;

  const CategoryLineChart({
    super.key,
    required this.aspectRatio,
    required this.isExpanded,
    required this.isExpense,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.showIndividual,
    required this.onChangeType,
    required this.catList,
    required this.transactions,
  });

  @override
  State<CategoryLineChart> createState() => _CategoryLineChartState();
}

class _CategoryLineChartState extends State<CategoryLineChart> {
  List<Color> gradientColors = [
    Colors.purple[200]!,
    Colors.purple[400]!,
  ];

  bool _showIndividual = false;
  late List<DateTime> dates;
  late List<FlSpot> sumChartSpots;
  late List<List<FlSpot>> individualChartSpots;
  late double sumChartMaxY;
  late double individualChartMaxY;

  void onLoad() {
    setState(() {
      _showIndividual = widget.showIndividual;
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

      // get the data for sum line chart
      sumChartSpots = StatisticsHelper.getLineChartData(widget.transactions, dates, days);
      sumChartMaxY = StatisticsHelper.getLineChartMaxY(sumChartSpots);

      // get the data for individual line chart
      List<List<Transaction>> groupedTransactions = StatisticsHelper.categorizeTransactions(widget.transactions, widget.catList);
      individualChartSpots = [];
      List<FlSpot> tmp = [];
      for (List<Transaction> group in groupedTransactions) {
        individualChartSpots.add(StatisticsHelper.getLineChartData(group, dates, days));
        tmp.addAll(individualChartSpots.last);
      }
      individualChartMaxY = StatisticsHelper.getLineChartMaxY(tmp);
    });
  }

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  void didUpdateWidget(covariant CategoryLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showIndividual = !_showIndividual;
                  });
                  widget.onChangeType();
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: Center(
                      child: Icon(
                        Icons.refresh_outlined,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              _showIndividual
              ? 'Category ${widget.isExpense ? "Expenses" : "Income"} x Period'
              : 'Total ${widget.isExpense ? "Expenses" : "Income"} x Period',
              style: TextStyle(
                color: AppColor.darkText,
                fontSize: 16.sp,
              ),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: 5.h),
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: LineChart(
            _showIndividual ? individualData() : sumData(),
          )
        )
      ]
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      fontSize: 12.sp,
    );
    Widget text;
    if (value.truncateToDouble() == value) {
      int day = dates[value.toInt()].day;
      int month = dates[value.toInt()].month;
      int year = dates[value.toInt()].year;
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

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      fontSize: 12.sp,
    );

    double maxY = _showIndividual ? individualChartMaxY : sumChartMaxY;
    double interval = getYIntervals(maxY);
    int numOfLine = maxY ~/ interval;
    List<double> tmp = !widget.isExpanded
        ? [0, interval * (numOfLine ~/ 2), maxY]
        : [0, interval * (numOfLine ~/ 4), interval * (numOfLine ~/ 2), interval * (3 * numOfLine ~/ 4), maxY];

    if (tmp.any((yVal) => (yVal - value).abs() < 0.01)) {
      return SideTitleWidget(
        meta: meta,
        child: Text(
          meta.formattedValue,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: style,
        ),
      );
    }

    return Container();
  }

  FlGridData gridData(double maxY) {
    double interval = getYIntervals(maxY);
    int numOfLine = maxY ~/ interval;
    List<double> tmp = !widget.isExpanded
      ? [0, interval * (numOfLine ~/ 2), maxY]
      : [0, interval * (numOfLine ~/ 4), interval * (numOfLine ~/ 2), interval * (3 * numOfLine ~/ 4), maxY];
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: getYIntervals(_showIndividual ? individualChartMaxY : sumChartMaxY),
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {

        if (tmp.any((yVal) => (yVal - value).abs() < 0.01)) {
          return FlLine(
            color: Colors.grey,
            strokeWidth: 1.w,
          );
        } else {
          return const FlLine(
            color: Colors.transparent, // Or use show: false for older versions
            strokeWidth: 0,
          );
        }
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.grey,
          strokeWidth: 1.w,
        );
      },
    );
  }

  double getYIntervals(double maxY) {
    if (maxY <= 1000) {
      return 1;
    } else {
      return maxY / 1000;
    }
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: getYIntervals(_showIndividual ? individualChartMaxY : sumChartMaxY),
        getTitlesWidget: leftTitleWidgets,
        reservedSize: 42,
      ),
    ),
  );

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: Border.all(color: AppColor.quaternary),
  );

  LineTouchData get lineTouchData => LineTouchData(
    enabled: true,
    touchTooltipData: LineTouchTooltipData(
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipColor: (group) => Colors.white,
      tooltipMargin: 0,
      getTooltipItems: (List<LineBarSpot> touchedSpots) {
        return touchedSpots.map((LineBarSpot touchedSpot) {
          return LineTooltipItem(
            '${widget.currency.toString()} ${touchedSpot.y.toStringAsFixed(2)}',
            TextStyle(
              color: touchedSpot.bar.color,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList();
      },
    ),
  );


  LineChartData sumData() {
    return LineChartData(
      gridData: gridData(_showIndividual ? individualChartMaxY : sumChartMaxY),
      titlesData: titlesData,
      borderData: borderData,
      minX: 0,
      maxX: dates.length - 1,
      minY: 0,
      maxY: sumChartMaxY,
      lineTouchData: lineTouchData,
      lineBarsData: [
        LineChartBarData(
          spots: sumChartSpots,
          isCurved: true,
          preventCurveOverShooting: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2.w,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> individualLineData() {
    List<LineChartBarData> lineChartBarData = [];
    for (int i = 0; i < individualChartSpots.length; i++) {
      Color color = widget.catList[i].color;
      lineChartBarData.add(
        LineChartBarData(
          isCurved: true,
          preventCurveOverShooting: true,
          color: color,
          barWidth: 2.w,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.5)]
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
          spots: individualChartSpots[i],
        )
      );
    }
    return lineChartBarData;
  }

  LineChartData individualData() {
    return LineChartData(
      gridData: gridData(_showIndividual ? individualChartMaxY : sumChartMaxY),
      titlesData: titlesData,
      borderData: borderData,
      lineBarsData: individualLineData(),
      lineTouchData: lineTouchData,
      minX: 0,
      maxX: dates.length - 1,
      minY: 0,
      maxY: individualChartMaxY,
    );
  }
}
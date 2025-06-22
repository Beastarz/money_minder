import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/statistics_page/statistics_helper.dart';

import '../../../models/currency.dart';
import '../../../style/app_color.dart';
import '../../categories_page/category_button.dart';

class CategoryBarChart extends StatefulWidget {

  final double aspectRatio;
  final bool isExpanded;
  final bool isExpense;
  final Currency currency;
  final List<CategoryProp> catList;

  const CategoryBarChart({
    required this.aspectRatio,
    required this.isExpanded,
    required this.isExpense,
    required this.currency,
    required this.catList,
    super.key
  });

  @override
  State<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends State<CategoryBarChart> {

  int touchedGroupIndex = -1;
  // late List<CategoryProp> dataList;
  late double maxY;

  BarChartGroupData generateBarGroup(int x, Color color, double value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 6,
        ),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0] : [],
    );
  }

  void onLoad() {
    setState(() {
      maxY = StatisticsHelper.getBarChartMaxY(widget.catList);
    });
  }


  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  void didUpdateWidget(covariant CategoryBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catList != widget.catList) onLoad();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'Category Total ${widget.isExpense ? "Expenses" : "Income"}',
            style: TextStyle(
              color: AppColor.darkText,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 5),
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              rotationQuarterTurns: 4,
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColor.quaternary),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  drawBelowEverything: true,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          meta.formattedValue,
                          style: TextStyle(
                            color: AppColor.darkText,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      return SideTitleWidget(
                        meta: meta,
                        child: _IconWidget(
                          color: widget.catList[index].color,
                          icon: widget.catList[index].icon,
                          isSelected: touchedGroupIndex == index,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.black.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              barGroups: widget.catList.asMap().entries.map((e) {
                final index = e.key;
                final data = e.value;
                return  generateBarGroup(
                  index,
                  data.color,
                  data.actualAmount
                );
              }).toList(),
              maxY: maxY,
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
                    return BarTooltipItem(
                      "${widget.currency.toString()} ${rod.toY.toStringAsFixed(2)}",
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
            ),
          ),
        ),
      ],
    );
  }
}

class _IconWidget extends ImplicitlyAnimatedWidget {
  const _IconWidget({
    required this.color,
    required this.icon,
    required this.isSelected,
  }) : super(duration: const Duration(milliseconds: 300));
  final Color color;
  final Icon icon;
  final bool isSelected;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _IconWidgetState();
}

class _IconWidgetState extends AnimatedWidgetBaseState<_IconWidget> {
  Tween<double>? _rotationTween;

  @override
  Widget build(BuildContext context) {
    final double rotation = 0;
    final double scale = 1 + _rotationTween!.evaluate(animation) * 0.25;
    return Transform(
      transform: Matrix4.rotationZ(rotation).scaled(scale, scale),
      origin: const Offset(14, 14),
      child: Icon(
        widget.icon.icon,
        color: widget.color,
        size: 28,
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _rotationTween = visitor(
      _rotationTween,
      widget.isSelected ? 1.0 : 0.0,
          (dynamic value) => Tween<double>(
        begin: value as double,
        end: widget.isSelected ? 1.0 : 0.0,
      ),
    ) as Tween<double>?;
  }
}
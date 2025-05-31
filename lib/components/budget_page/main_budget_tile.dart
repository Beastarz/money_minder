import 'package:flutter/material.dart';
import 'package:money_minder/utils/show_money.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';
import 'budget_helper.dart';
import 'budget_tile.dart';

class MainBudgetTile extends StatefulWidget {

  final BudgetTileProp prop;
  final bool isCurve;
  final double textWidth;

  const MainBudgetTile({
    super.key,
    required this.prop,
    required this.textWidth,
    this.isCurve = true,
  });

  @override
  State<MainBudgetTile> createState() => _MainBudgetTileState();
}

class _MainBudgetTileState extends State<MainBudgetTile> {

  final GlobalKey _myWidgetKey = GlobalKey();
  double? _widgetHeight;
  double? _widgetWidth;

  void _getSizeAndPosition() {
    if (_myWidgetKey.currentContext != null) {
      final RenderBox renderBox = _myWidgetKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _widgetHeight = renderBox.size.height;
        _widgetWidth = renderBox.size.width;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a post-frame callback to get the size after the widget is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSizeAndPosition();
    });
  }

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen  = MediaQuery.of(context).size.width <= 360;
    final double topFactor = isSmallScreen ? 1.0 : 1.5;
    final double bottomFactor = isSmallScreen ? 0.8 : 1.0;
    final double borderRadius = 8;
    double fraction = widget.prop.budget <= 0
        ? 0.02
        : widget.prop.actualAmount / widget.prop.budget;
    fraction = fraction.clamp(0.03, 1.0);
    Color leftColor = BudgetHelper.lightenColor(widget.prop.color, 0.75);
    Color rightColor = BudgetHelper.lightenColor(widget.prop.color, 0.9);

    return Container(
      key: _myWidgetKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.isCurve ? borderRadius : 0),
        color: rightColor,
      ),
      child: Stack(
        // fit: StackFit.expand,
        children: [

          Container(
            width: _widgetWidth == null  ? 0 : _widgetWidth! * fraction,
            height: _widgetHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(widget.isCurve ? borderRadius : 0),
                  right: Radius.circular(borderRadius),
              ),
              color: leftColor,
            ),
            child: Text(""),
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.transparent,
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSize.smallPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.prop.label,
                        style: TextStyle(
                          fontSize: AppSize.heading3 * topFactor,
                          color: AppColor.darkText,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ShowMoney(
                        mainCurrency: widget.prop.mainCurrency,
                        amount: widget.prop.actualAmount,
                        text: BudgetHelper.textMap[widget.prop.type]!,
                        color: widget.prop.color,
                        factor: bottomFactor,
                        width: widget.textWidth,
                      )
                    ],
                  ),
                  Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ShowMoney(
                        mainCurrency: widget.prop.mainCurrency,
                        amount: widget.prop.budget - widget.prop.actualAmount,
                        text: "",
                        color: widget.prop.color,
                        factor: topFactor,
                        isStart: false,
                        width: widget.textWidth,
                      ),
                      ShowMoney(
                        mainCurrency: widget.prop.mainCurrency,
                        amount: widget.prop.budget,
                        text: "budgeted",
                        color: widget.prop.color,
                        factor: bottomFactor,
                        isStart: false,
                        width: widget.textWidth,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
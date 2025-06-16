import 'package:flutter/material.dart';

import '../../style/app_size.dart';

class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.isExpanded,
    required this.shrinkChart,
    required this.child,
  });

  final Widget child;
  final bool isExpanded;
  final void Function()? shrinkChart;

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    double height = isExpanded
      ? MediaQuery.of(context).size.width * 0.8
      : isSmallScreen ? 145 : 200 - AppSize.smallPadding;
    double width = isExpanded
      ? MediaQuery.of(context).size.height * 0.8
      : MediaQuery.of(context).size.width * 0.9;

    return Stack(
      children: <Widget>[
        Center(
          child: Container(
              padding: EdgeInsets.all(AppSize.smallPadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              height: height,
              width: width,
              child: child
          ),
        ),

        isExpanded
        ? Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
              shrinkChart!();
            },
            icon: const Icon(Icons.fullscreen_exit_outlined,
              size: 30
            ),
          ),
        )
        : SizedBox.shrink(),
      ],
    );
  }
}

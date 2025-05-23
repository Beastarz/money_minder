import 'package:flutter/material.dart';

import '../../style/app_size.dart';

/// bottom sheet that will appear when the user taps on the calendar icon
class PeriodBottomSheet extends StatelessWidget {

  /// variables
  // title of the bottom sheet
  final String title;
  // widgets that will be displayed in the bottom sheet
  final List<Widget> children;

  const PeriodBottomSheet({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSize.bigPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Period',
            style: TextStyle(
                fontSize: AppSize.heading1,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: children
          ),
        ],
      ),
    );
  }
}

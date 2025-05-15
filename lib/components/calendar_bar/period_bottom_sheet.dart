import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class PeriodBottomSheet extends StatelessWidget {
  const PeriodBottomSheet({super.key});

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
                color: AppColor.lightText,
                fontSize: AppSize.heading1,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _periodTile(context, 'Select range', Icons.edit_calendar,
                width: MediaQuery.of(context).size.width * 0.84 + 12),
              _periodTile(context, 'All time', Icons.all_inclusive),
              _periodTile(context, 'Week\n11 – 17 May', Icons.calendar_view_week),
              _periodTile(context, 'Today\n15 May', Icons.today),
              _periodTile(context, 'Select day', Icons.date_range),
              _periodTile(context, 'Month\nMay 2025', Icons.calendar_month),
              _periodTile(context, 'Year\n2025', Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodTile(BuildContext context, String label, IconData icon,
    {double height = 0, double width = 0}) {
    return MaterialButton(
      onPressed: () {},
      height: height == 0 ? MediaQuery.of(context).size.width * 0.30 : height,
      minWidth: width == 0 ? MediaQuery.of(context).size.width * 0.42 : width,
      padding: EdgeInsets.all(AppSize.smallPadding),
      color: AppColor.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColor.lightIcon, size: AppSize.bigIcon),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                color: AppColor.lightText,
                fontSize: AppSize.heading2
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

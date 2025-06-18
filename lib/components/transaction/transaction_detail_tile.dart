import 'package:flutter/material.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

/// the button that will appear in the period bottom sheet
class TransactionDetailTile extends StatelessWidget {

  /// variables
  final String label;
  final Icon icon;
  final void Function()? onPressed;

  const TransactionDetailTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: MediaQuery.of(context).size.width * 0.15,
      minWidth: MediaQuery.of(context).size.width * 0.40,
      padding: EdgeInsets.all(AppSize.smallPadding),
      color: AppColor.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      elevation: 1,
      child: Column(
        children: [
          icon,
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: AppSize.heading2
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

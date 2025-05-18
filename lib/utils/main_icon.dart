import 'package:flutter/material.dart';
import 'package:money_minder/style/app_color.dart';

import '../style/app_size.dart';

class MainIcon extends StatelessWidget {
  final Icon icon;
  final Color color;
  final bool rounded;
  final bool isMain;

  const MainIcon({super.key, required this.icon, required this.color, this.rounded = true, this.isMain = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.mainIcon * 1.5,
      width: AppSize.mainIcon * 1.5,
      decoration: BoxDecoration(
        borderRadius: rounded ? null : BorderRadius.circular(12),
        shape: rounded ? BoxShape.circle : BoxShape.rectangle,
        color: color,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          icon.icon,
          color: AppColor.lightIcon,
          size: AppSize.mainIcon,
        ),
      ),
    );
  }
}

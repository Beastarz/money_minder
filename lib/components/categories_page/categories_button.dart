import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../style/app_size.dart';

class CategoriesButton extends StatelessWidget {

  /// variable
  // label of the categories
  final String label;
  // icon path of the categories
  final String iconPath;
  // TODO: add the onPressed function
  void Function()? categoriesButtonOnPressed;

  CategoriesButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.categoriesButtonOnPressed,
  });

  // Widget for the category buttons
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Use SvgPicture.asset for SVG icons
        SizedBox(
          width: 50,
          height: 50,
          child: ElevatedButton(
            onPressed: categoriesButtonOnPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.grey[200],
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 30,
              height: 30
              // ignore: deprecated_member_use// Example color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '\$0', // Replace with actual amount
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

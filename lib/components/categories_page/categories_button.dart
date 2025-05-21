import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_page_helper.dart';

import '../../style/app_color.dart';

class CategoriesButtonProps {

  /// variable
  final String label;
  final String iconPath;
  Color color;
  double actualAmount;
  double expectedAmount;
  bool isAddButton;

  CategoriesButtonProps({
    required this.label,
    required this.iconPath,
    required this.color,
    required this.actualAmount,
    required this.expectedAmount,
    this.isAddButton = false,
  });
}

class AddCategoriesButtonProps extends CategoriesButtonProps {
  AddCategoriesButtonProps() // No need for parameters if they are all defaulted
      : super(
    label: 'Add',
    iconPath: 'lib/assets/icons/add.svg',
    color: AppColor.secondary,
    actualAmount: 0,
    expectedAmount: 0,
    isAddButton: true, // Override parent's default for showDetail
  );
}

class CategoriesButton extends StatelessWidget {

  /// variable
  // props contains all the data required to build a category button
  final CategoriesButtonProps props;

  const CategoriesButton({
    super.key,
    required this.props,
  });

  // Widget for the category buttons
  @override
  Widget build(BuildContext context) {

    Color topColor = props.color.withAlpha((0.3 * 255).round());
    Color bottomColor = props.color;
    double fraction = props.expectedAmount == 0
        ? 0.00
        : 1 - (props.actualAmount / props.expectedAmount);

    // Use SvgPicture.asset for SVG icons
    Widget buttonIcon = CategoriesPageHelper.generateButtonIcon(props.iconPath);

    // button background color gradient reflect the portion of
    // expense over budget
    Widget buttonContent = Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [topColor, topColor, bottomColor, bottomColor], // Define the colors for the gradient
            stops: [0.0, fraction, fraction, 1.0], // Define the stops for the gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          border: props.isAddButton // addButton does not have solid border
          ? Border.all(
            color: Colors.transparent,
            width: 0,
          )
          : Border.all(
            color: props.color,
            width: 2.0,
          )
        ),
        child: Material(
          color: Colors.transparent, // Make Material widget transparent, to see the gradient underneath
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // print("${props.label} button tapped!");
            },
            customBorder: const CircleBorder(),
            splashColor: AppColor.quaternary.withAlpha((0.2 * 255).round()),
            highlightColor: AppColor.quaternary.withAlpha((0.1 * 255).round()),
            child: Center(child: buttonIcon),
          ),
        ),
    );

    // add dotted border to add button
    Widget button = props.isAddButton
      ? DottedBorder(
        options: CircularDottedBorderOptions(
          dashPattern: [6, 3],
          strokeWidth: 2,
          padding: EdgeInsets.zero,
          color: AppColor.tertiary,
        ),
        child: buttonContent
        )
      : buttonContent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 4),
        Text(
          props.label,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        !props.isAddButton ?
        Column(
          children: [
            const SizedBox(height: 2),
            Text(
              props.expectedAmount != 0
              ? '\$${props.actualAmount.toStringAsFixed(2)} / '
                  '${props.expectedAmount.toStringAsFixed(2)}'
              : '\$${props.actualAmount.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 10),
            ),
          ],
        )
        : const SizedBox(height: 0),
      ],
    );
  }
}

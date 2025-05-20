import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../style/app_color.dart';

class CategoriesButtonProps {

  /// variable
  final String label;
  final String iconPath;
  // final void Function()? categoriesButtonOnPressed;
  Color color;
  double expense;
  double budget;
  bool isAddButton;

  CategoriesButtonProps({
    required this.label,
    required this.iconPath,
    // required this.categoriesButtonOnPressed,
    required this.color,
    required this.expense,
    required this.budget,
    this.isAddButton = false,
  });
}

class AddCategoriesButtonProps extends CategoriesButtonProps {
  AddCategoriesButtonProps() // No need for parameters if they are all defaulted
      : super(
    label: 'Add',
    iconPath: 'lib/assets/icons/add.svg',
    color: AppColor.secondary,
    expense: 0,
    budget: 0,
    isAddButton: true, // Override parent's default for showDetail
  );
}

class CategoriesButton extends StatelessWidget {

  /// variable
  CategoriesButtonProps props;

  CategoriesButton({
    super.key,
    required this.props,
  });

  // Widget for the category buttons
  @override
  Widget build(BuildContext context) {

    Color topColor = props.color.withAlpha((0.3 * 255).round());
    Color bottomColor = props.color;
    double fraction = props.budget == 0
        ? 0.00
        : 1 - (props.expense / props.budget);

    // Use SvgPicture.asset for SVG icons
    Widget buttonIcon = SvgPicture.asset(
      props.iconPath,
      colorFilter: ColorFilter.mode(
        AppColor.lightIcon,
        BlendMode.srcIn,
      ),
      width: 30,
      height: 30,
    );

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
          shape: BoxShape.circle, // Make the container circular
          border: props.isAddButton
          ? Border.all(
            color: Colors.transparent,
            width: 0,
          )
          : Border.all(
            color: props.color, // Border color, transparent for add button
            width: 2.0,
          )
        ),
        child: Material( // Material for ink splash effects if needed
          color: Colors.transparent, // Make Material widget transparent
          shape: const CircleBorder(), // Match shape for ink effects
          clipBehavior: Clip.antiAlias, // Clip ink effects to circle
          child: InkWell( // Use InkWell for tap effects if ElevatedButton is too complex here
            onTap: () {
              // Handle button tap
              print("${props.label} button tapped!");
            },
            customBorder: const CircleBorder(),
            splashColor: props.color.withAlpha((0.2 * 255).round()), // Optional splash
            highlightColor: props.color.withAlpha((0.1 * 255).round()), // Optional highlight
            child: Center(child: buttonIcon),
          ),
        ),
    );

    // build the button
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
              props.budget != 0
              ? '\$${props.expense.toStringAsFixed(2)} / '
                  '${props.budget.toStringAsFixed(2)}'
              : '\$${props.expense.toStringAsFixed(2)}',
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

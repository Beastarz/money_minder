import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/currency.dart';

import '../../style/app_color.dart';

class CategoryButtonProps {

  /// variable
  final int position; // index of the button in the list, affecting the sequence
  final String label; // button label
  final Icon icon; // icon of the categories
  final Color color; // button color
  final double actualAmount; // expense / income
  final double budget; // budget / expected income
  final bool isExpense; // indicated if it is expense or income
  int pieTouchedIndex = -1; // the index of the clicked pie data
  final bool isAddButton; // indicated if it is the addButton

  CategoryButtonProps({
    required this.position,
    required this.label,
    required this.icon,
    required this.color,
    required this.actualAmount,
    required this.budget,
    required this.isExpense,
    this.pieTouchedIndex = -1,
    this.isAddButton = false,
  });
}

class AddCategoriesButtonProps extends CategoryButtonProps {
  AddCategoriesButtonProps(int index) // No need for parameters if they are all defaulted
      : super(
    position: index,
    label: 'Add',
    icon: Icon(
      IconData(0xe145, fontFamily: "MaterialSymbolsOutlined")
    ),
    color: AppColor.secondary,
    actualAmount: 0,
    budget: 0,
    isExpense: false,
    pieTouchedIndex: -1,
    isAddButton: true, // Override parent's default for showDetail
  );
}

class CategoriesButton extends StatefulWidget {

  /// variable
  // props contains all the data required to build a category button
  final CategoryButtonProps props;
  // callback function when the categories button is pressed
  final void Function(CategoryButtonProps) categoriesButtonOnPressed;
  final Currency mainCurrency;

  const CategoriesButton({
    super.key,
    required this.props,
    required this.categoriesButtonOnPressed,
    required this.mainCurrency,
  });

  @override
  State<CategoriesButton> createState() =>
      _CategoriesButtonState();
}

class _CategoriesButtonState extends State<CategoriesButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _pauseTimer; // Timer for the 0.25 second pause
  bool isLooping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      // Duration for one way (either enlarge or shrink)
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2) // Enlarge to 130%
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Listen to the animation status
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // This means the animation has returned to its start (shrink completed)
        if (isLooping) {
          // PAUSE for 0.25 second
          _pauseTimer = Timer(const Duration(milliseconds: 250), () {
            // After 0.25 second, REVERSE the animation (shrink back)
            if (mounted) { // Ensure the widget is still in the tree
              _controller.forward();
            }
          });
        }
      }
    });
  }

  void _triggerPop() {
    // If not already animating, and timer isn't active (to prevent re-trigger during pause)
    if (!_controller.isAnimating && (_pauseTimer == null || !_pauseTimer!.isActive)) {
      _controller.forward(from: 0.0); // Start the enlarge animation from the beginning
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CategoryButtonProps props = widget.props;
    Color topColor = props.color.withAlpha((0.3 * 255).round());
    Color bottomColor = props.color;
    double fraction = props.budget == 0
        ? 0.00
        : 1 - (props.actualAmount / props.budget);
    fraction = fraction < 0 ? 0 : fraction;

    setState(() {
      isLooping = props.pieTouchedIndex == props.position;
    });
    // if the pieData corresponding to this categories is clicked
    // trigger the animation
    if (props.pieTouchedIndex == props.position) {
      _triggerPop();
    }

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
            if (props.isAddButton) {
              return;
            }
            widget.categoriesButtonOnPressed(props);
          },
          customBorder: const CircleBorder(),
          splashColor: AppColor.quaternary.withAlpha((0.2 * 255).round()),
          highlightColor: AppColor.quaternary.withAlpha((0.1 * 255).round()),
          child: Center(child: props.icon),
        ),
      ),
    );

    // add dotted border and animation to add button
    Widget button = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: props.isAddButton
            ? DottedBorder(
            options: CircularDottedBorderOptions(
              dashPattern: [6, 3],
              strokeWidth: 2,
              padding: EdgeInsets.zero,
              color: AppColor.tertiary,
            ),
            child: buttonContent
        )
            : buttonContent
    );

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
                  ? '${widget.mainCurrency.toString()} ${props.actualAmount.toStringAsFixed(2)} / '
                  '${props.budget.toStringAsFixed(2)}'
                  : '${widget.mainCurrency.toString()} ${props.actualAmount.toStringAsFixed(2)}',
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

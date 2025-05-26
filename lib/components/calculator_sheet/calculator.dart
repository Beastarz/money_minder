import 'package:flutter/material.dart';
import 'package:money_minder/components/calculator_sheet/calculator_button.dart';
import 'package:money_minder/components/calculator_sheet/reverse_ellipsis_text.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';
import 'package:money_minder/style/app_color.dart';

import '../../style/app_size.dart';

import 'package:math_expressions/math_expressions.dart';

import '../calendar_bar/calendar_selector_helper.dart';
import '../calendar_bar/period_tile.dart';


/// to use CalculatorScreen, you need to pass in a list of CalculatorButtonProps
/// List<String> buttonTexts = ['1', '2', '3', ....]
/// backspace is '<', calendar is 'calendar'
/// check is '✓' (!!!!! don't enter this, it is handled explicitly, cause it
///   need to swap between '=' and '✓'. It is contained in calculator by default)
/// final buttonProps = CalculatorHelper.convertToCalButProps(buttonTexts)
/// CalculatorScreen(buttonProps: buttonProps);
///
/// in builder, pass in context, as we will need to show another modal bottom
/// sheet inside this modal bottom sheet, need to have Scaffold as its parent
class Calculator extends StatefulWidget {
  
  /// variable
  // the button on the calculator
  final List<CalculatorButtonProps> buttonProps;
  // final Widget topContent;
  
  const Calculator({
    super.key,
    required this.buttonProps,
    // required this.topContent,
  });

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _currentAmount = '0'; // This will be displayed in the UI
  final String _currency = '\$'; // Default currency symbol
  final List<String> _operators = ['+', '-', 'x', '÷', '*', '/']; // operator symbol
  final List<String> _numbers = ['0']; // numbers in input (remove all operator)
  String _lastButton = '✓';

  // This method would be called by the calculator buttons
  void _onButtonPressed(String buttonText) {
    setState(() {

      String lastChar = _currentAmount.substring(_currentAmount.length - 1);
      int inputLen = _currentAmount.length;
      int numLen = _numbers.length;

      if (buttonText == 'C') {

        // clear the input
        _currentAmount = '0';
        _numbers.clear();
        _numbers.add('0');

      } else if (buttonText == '<') {

        // Remove the last character
        if (inputLen > 1) {
          _currentAmount = _currentAmount.substring(0, inputLen - 1);
          if (_operators.contains(lastChar)) {
            _numbers.removeLast();
          } else {
            _numbers[numLen - 1] = _numbers[numLen - 1]
                .substring(0, _numbers[numLen - 1].length - 1);
          }
        } else {
          // Reset to 0 if the string is empty
          _currentAmount = '0';
          _numbers.clear();
          _numbers.add('0');
        }

      } else if (buttonText == '=') {

        try {

          Expression exp = ShuntingYardParser().parse(_currentAmount);
          // Create a context model (for variables, if any)
          ContextModel cm = ContextModel();

          // Evaluate the expression
          double evalResult = exp.evaluate(EvaluationType.REAL, cm);

          // Format the result (e.g., remove trailing .0 if it's an integer)
          _currentAmount = evalResult.toStringAsFixed(
            evalResult.truncateToDouble() == evalResult
              ? 0
              : 2); // Format to 0 or 2 decimal places

          // handle unexpected output (happen when input is invalid)
          // e.g. 0 / 2, 0 / 0
          if (_currentAmount == 'Infinity' || _currentAmount == 'NaN') {
            // Reset to 0 if the string is empty
            _currentAmount = '0';
            _numbers.clear();
            _numbers.add('0');
          } else {
            // Update the numbers list
            _numbers.clear();
            _numbers.add(_currentAmount);
          }

        } catch (e) {
          _currentAmount = '0';
          _numbers.clear();
          _numbers.add('0');
        }

      } else if (buttonText == '✓') {

        // TODO: save new transaction

      } else if (buttonText == '\$') {

        // TODO: select currency

      } else if (buttonText == 'calendar') {

        final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColor.secondary,
          builder: (periodSheetContext) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.80,
              builder: (context, ScrollController scrollController) =>
              SingleChildScrollView(
                controller: isSmallScreen ? scrollController : null,
                child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: PeriodBottomSheet(
                  title: 'Date',
                  children: [
                    /// select any date
                    PeriodTile(
                        parentContext: context,
                        label: 'Select day',
                        icon: Icons.date_range,
                        onPressed: () {
                          CalendarSelectorHelper.selectDate(context, (date) => {});
                        },
                        width: MediaQuery.of(context).size.width * 0.84 + 12,
                    ),

                    /// select yesterday
                    PeriodTile(
                        parentContext: context,
                        label: 'Yesterday',
                        selected: '22 May 2025',
                        icon: Icons.mode_night_rounded,
                        onPressed: () {},
                    ),

                    /// select today
                    PeriodTile(
                      parentContext: context,
                      label: 'Today',
                      selected: '23 May 2025',
                      icon: Icons.sunny,
                      onPressed: () {},
                    ),

                    /// select recurrence
                    PeriodTile(
                      parentContext: context,
                      label: 'Recurrence',
                      selected: 'None',
                      icon: Icons.repeat,
                      onPressed: () {},
                    ),

                    /// select reminder
                    PeriodTile(
                      parentContext: context,
                      label: 'Reminder',
                      selected: 'None',
                      icon: Icons.access_alarm_sharp,
                      onPressed: () {},
                    ),
                  ]),
                            ),
              ));
          }
        );

      } else if (_operators.contains(buttonText)) {

        // Check if the previous string is an operator
        if (_operators.contains(lastChar)) {
          // Replace the operator if it's already there
          if (buttonText == 'x') {
            buttonText = '*';
          } else if (buttonText == '÷') {
            buttonText = '/';
          }
          _currentAmount =
              _currentAmount.substring(0, _currentAmount.length - 1)
              + buttonText;
        } else {
          // Handle operators
          if (buttonText == '÷') {
            // Handle division operator
            _currentAmount += '/';
          }
          else if (buttonText == 'x') {
            // Handle multiplication operator
            _currentAmount += '*'; // Use standard operator for calculation
          }
          else if (buttonText == '-' || buttonText == '+') {
            // Handle subtraction operator
            if (_currentAmount == '0') {
              _currentAmount = buttonText;
            } else {
              _currentAmount += buttonText;
            }
          }
          _numbers.add("");
        }
      }
      else if (buttonText == '.') {

        // Allow only one decimal point
        if (!_numbers[numLen - 1].contains('.')) {
          _currentAmount += ".";
          _numbers[numLen - 1] += ".";
        }

      } else {

        // Handle number input
        // ensure only have two decimal places
        if (_numbers[numLen - 1] == '0') {
          _currentAmount =
              _currentAmount.substring(0, _currentAmount.length - 1)
              + buttonText;
          _numbers[numLen - 1] = buttonText;
        } else if(_numbers[numLen - 1].contains('.')) {
          int decimalPlace = _numbers[numLen - 1].length -
              _numbers[numLen - 1].indexOf('.') - 1;
          if (decimalPlace < 2) {
            _currentAmount += buttonText;
            _numbers[numLen - 1] += buttonText;
          }
        } else {
          _currentAmount += buttonText;
          _numbers[numLen - 1] += buttonText;
        }
      }
      _lastButton = _numbers.length == 1 ? '✓' : '=';
    });
  }

  @override
  Widget build(BuildContext context) {

    List<CalculatorButtonProps> buttonProps = widget.buttonProps;
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
    
    return Container(
      height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.60 : 0.45),
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSize.borderRadius)
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: ReverseEllipsisText(
              '$_currency $_currentAmount',
              style: TextStyle(
                fontSize: isSmallScreen
                    ? AppSize.heading1
                    : AppSize.heading1 * 1.5,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText,
              ),
            ),
          ),
          SizedBox(height: AppSize.smallPadding), // small padding
          // Notes input
          TextField(
            decoration: InputDecoration(
              hintText: 'Notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSize.borderRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColor.primary,
              contentPadding: EdgeInsets.all(AppSize.smallPadding),
            ),
            style: TextStyle(fontSize: isSmallScreen
                ? AppSize.heading3
                : AppSize.heading3 * 1.5),
          ),
          SizedBox(height: AppSize.smallPadding), // small padding
          // Calculator Grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.2, // Adjust aspect ratio for button size
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return index == 19
                    ? CalculatorButton(
                    props: CalculatorButtonProps(
                      text: _lastButton,
                      icon: _lastButton == '✓' ? Icons.check : null,
                      backgroundColor: Colors.greenAccent,
                      textColor: AppColor.lightText,
                    ),
                    onPressed: () {
                      _onButtonPressed(_lastButton);
                    }
                )
                    : CalculatorButton(
                    props: buttonProps[index],
                    onPressed: () {
                      _onButtonPressed(buttonProps[index].text);
                    }
                );
              },
            ),
          ),
          // show setting at the bottom
          SizedBox(height: AppSize.smallPadding), // small padding
          Text(
            'Today, ${DateTime.now().day} ${
                _getMonthName(DateTime.now().month)
            } ${DateTime.now().year}',
            style: TextStyle(
                color: AppColor.darkText,
                fontSize: isSmallScreen
                    ? AppSize.heading3
                    : AppSize.heading3 * 1.5),
          )
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'JAN';
      case 2: return 'FEB';
      case 3: return 'MAR';
      case 4: return 'APR';
      case 5: return 'MAY';
      case 6: return 'JUN';
      case 7: return 'JUL';
      case 8: return 'AUG';
      case 9: return 'SEP';
      case 10: return 'OCT';
      case 11: return 'NOV';
      case 12: return 'DEC';
      default: return '';
    }
  }
}
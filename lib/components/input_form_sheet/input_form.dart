import 'package:flutter/material.dart';
import 'package:money_minder/components/input_form_sheet/input_form_button.dart';
import 'package:money_minder/components/input_form_sheet/reverse_ellipsis_text.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';
import 'package:money_minder/style/app_color.dart';

import '../../models/currency.dart';
import '../../style/app_size.dart';

import 'package:math_expressions/math_expressions.dart';

import '../calendar_bar/calendar_selector_helper.dart';
import '../calendar_bar/period_tile.dart';


/// to use InputForm, you need to pass in a list of InputFormButtonProps
/// List\<String\> buttonTexts = ['1', '2', '3', ....]
/// backspace is '<', calendar is 'calendar'
/// check is '✓' (!!!!! don't enter this, it is handled explicitly, cause it
///   need to swap between '=' and '✓'. It is contained in input form by default)
/// final buttonProps = InputFormHelper.convertToCalButProps(buttonTexts)
/// InputForm(buttonProps: buttonProps);
class InputForm extends StatefulWidget {
  
  /// variable
  // the button on the inputForm
  final List<InputFormButtonProps> buttonProps;
  final bool showNotes; // show notes input
  final double defaultValue; // default value of the input
  final Currency mainCurrency; // default currency of the input
  
  const InputForm({
    super.key,
    required this.buttonProps,
    this.showNotes = true,
    this.defaultValue = 0,
    required this.mainCurrency,
  });

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {

  String _currentAmount = '0'; // This will be displayed in the UI
  final List<String> _operators = ['+', '-', 'x', '÷', '*', '/']; // operator symbol
  final List<String> _numbers = ['0']; // numbers in input (remove all operator)
  String _lastButton = '✓';

  // This method would be called by the input form buttons
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

      } else if (buttonText == 'budget') {

        // TODO : set budget for that month
        showModalBottomSheet(
            context: context,
            builder: (sheetContext) {
              return Container();
            }
        );

      }else if (buttonText == 'calendar') {

        final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColor.secondary,
          builder: (periodSheetContext) {
            return SafeArea(
              child: DraggableScrollableSheet(
                initialChildSize: isSmallScreen ? 1 : 0.85,
                expand: false,
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
                )),
            );
          }
        );

      } else if (_operators.contains(buttonText)) {

        // Check if the previous string is an operator
        if (_operators.contains(lastChar)) {
          // Replace the operator if it's already there
          if (buttonText == 'x') {
            buttonText = inputLen == 1 ? '0*' : '*';
          } else if (buttonText == '÷') {
            buttonText = inputLen == 1 ? '0/' : '/';
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
  void initState() {
    super.initState();
    setState(() {
      _currentAmount = widget.defaultValue.toStringAsFixed(2);
      _numbers.clear();
      _numbers.add(_currentAmount);
    });
  }

  @override
  Widget build(BuildContext context) {

    List<InputFormButtonProps> buttonProps = widget.buttonProps;
    final String currency = widget.mainCurrency.toString(); // Default currency symbol
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return Container(
      height: MediaQuery.of(context).size.height * (isSmallScreen
          ? widget.showNotes ? 0.60 : 0.45
          : widget.showNotes ? 0.45 : 0.40),
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
              '$currency $_currentAmount',
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

          !widget.showNotes
          ? SizedBox.shrink()
          : TextField(
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
          SizedBox(height: !widget.showNotes ? 0 : AppSize.smallPadding), // small padding
          // Input Form Grid
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
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
                  ? InputFormButton(
                  props: InputFormButtonProps(
                    text: _lastButton,
                    icon: _lastButton == '✓' ? Icons.check : null,
                    backgroundColor: Colors.greenAccent,
                    textColor: AppColor.lightText,
                  ),
                  onPressed: () {
                    _onButtonPressed(_lastButton);
                  }
              )
                  : InputFormButton(
                  props: buttonProps[index],
                  onPressed: () {
                    _onButtonPressed(buttonProps[index].text);
                  }
              );
            },
          ),
          // show setting at the bottom
          !widget.showNotes
              ? SizedBox.shrink()
              : SizedBox(height: 4), // small padding

          !widget.showNotes
            ? SizedBox.shrink()
            : Text(
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
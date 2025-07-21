
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/budget_page/budget_settings_page.dart';
import 'package:money_minder/components/input_form_sheet/input_keyboard_button.dart';
import 'package:money_minder/components/input_form_sheet/reverse_ellipsis_text.dart';
import 'package:money_minder/components/calendar_bar/period_bottom_sheet.dart';
import 'package:money_minder/models/recurrence.dart';
import 'package:money_minder/repositories/budget_repositories.dart';
import 'package:money_minder/style/app_color.dart';

import '../../models/category.dart';
import '../../models/currency.dart';
import '../../style/app_size.dart';

import 'package:math_expressions/math_expressions.dart';

import '../calendar_bar/calendar_selector_helper.dart';
import '../calendar_bar/period_tile.dart';
import '../categories_page/fast_note/fast_note_container.dart';


/// to use InputForm, you need to pass in a list of InputFormButtonProps
/// List\<String\> buttonTexts = ['1', '2', '3', ....]
/// backspace is '<', calendar is 'calendar'
/// check is '✓' (!!!!! don't enter this, it is handled explicitly, cause it
///   need to swap between '=' and '✓'. It is contained in input form by default)
/// final buttonProps = InputFormHelper.convertToCalButProps(buttonTexts)
/// InputForm(buttonProps: buttonProps);
class InputKeyboard extends StatefulWidget {
  
  /// variable
  // the button on the inputForm
  final List<InputFormButtonProps> buttonProps;
  final bool showNotes; // show notes input
  final Category? category;
  final double defaultValue; // default value of the input
  final DateTime? defaultDate; // default date of the input
  final RecurrenceType? defaultRecurrence; // default recurrence of the input
  final Currency mainCurrency; // default currency of the input
  final int categoryId; // for budget input form usage
  final double expenseAsBudget; // for budget input form usage
  final bool disabledBudgetDelete; // for budget input form usage
  final void Function(DateTime, double, String, int, RecurrenceType) onSubmit;
  final void Function(Currency) onCurrencyUpdate;
  final void Function()? onDeleteBudget;
  
  const InputKeyboard({
    super.key,
    required this.buttonProps,
    this.showNotes = true,
    this.category,
    this.defaultValue = 0,
    this.categoryId = 0,
    this.expenseAsBudget = 0,
    this.disabledBudgetDelete = false,
    required this.mainCurrency,
    required this.onSubmit,
    required this.onCurrencyUpdate,
    this.defaultDate,
    this.defaultRecurrence,
    this.onDeleteBudget,
  });

  @override
  State<InputKeyboard> createState() => _InputKeyboardState();
}

class _InputKeyboardState extends State<InputKeyboard> {

  String _currentAmount = '0'; // This will be displayed in the UI
  final List<String> _operators = ['+', '-', 'x', '÷', '*', '/']; // operator symbol
  final List<String> _numbers = ['0']; // numbers in input (remove all operator)
  String _lastButton = '✓';
  int _recurringMonths = 1;
  String _message = '';
  DateTime _currDate = DateTime.now();
  String _datePrefix = 'Today';
  RecurrenceType _recurrenceType = RecurrenceType.none;
  bool isRecurringBudget = false;
  bool _showError = false; // show error when user submit negative amount
  final TextEditingController _noteController = TextEditingController(text: '');
  final List<Currency> _currencies = Currency.currencies;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.defaultValue != 0) {
        _currentAmount = widget.defaultValue.toStringAsFixed(
            widget.defaultValue.truncateToDouble() == widget.defaultValue ? 0 : 2
        );
      }
      _numbers.clear();
      _numbers.add(_currentAmount);
      widget.defaultDate == null ? _currDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day) : _currDate = widget.defaultDate!;
      widget.defaultDate == null ? _datePrefix = 'Today' : _datePrefix = formatDate(_currDate, [DD]);
      widget.defaultRecurrence == null ? _recurrenceType = RecurrenceType.none : _recurrenceType = widget.defaultRecurrence!;

      // if showNotes == true, it is a budget input form, else transaction input form
      if (!widget.showNotes) {
        _message = _recurringMonths == 1 ? '' : 'Recurrence: $_recurringMonths months';
      } else  {
        _message = '$_datePrefix, ${formatDate(_currDate, [dd, ' ', M, ' ', yyyy])}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    List<InputFormButtonProps> buttonProps = widget.buttonProps;
    final String currency = widget.mainCurrency.toString(); // Default currency symbol
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSize.borderRadius)
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            _showError
            ? Text(
              "Please enter valid amount",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: isSmallScreen
                      ? AppSize.paragraph
                      : AppSize.paragraph * 1.2),
            )
            : SizedBox.shrink(),

            SizedBox(height: AppSize.smallPadding), // small padding

            // Notes input
            !widget.showNotes
            ? SizedBox.shrink()
            : TextField(
              controller: _noteController,
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

            // show fast notes
            widget.category == null
            ? SizedBox.shrink()
            : FastNoteContainer(
              color: widget.category!.color,
              categoryId: widget.category!.id,
              onTap: (note) {
                setState(() {
                  if (_noteController.text.isEmpty) {
                    _noteController.text = note;
                  } else {
                    _noteController.text += ', $note';
                  }
                });
              }
            ),

            SizedBox(height: widget.category == null ? 0 : AppSize.smallPadding), // small padding
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
            _message.isEmpty
                ? SizedBox.shrink()
                : SizedBox(height: 4), // small padding

            _message.isEmpty
              ? SizedBox.shrink()
              : Text(
                  _recurrenceType == RecurrenceType.none ? _message : '$_message, ${_recurrenceType.name[0].toUpperCase()}${_recurrenceType.name.substring(1)}',
                  style: TextStyle(
                      color: AppColor.darkText,
                      fontSize: isSmallScreen
                          ? AppSize.heading3
                          : AppSize.heading3 * 1.2),
                )
          ],
        ),
      ),
    );
  }

  /// change the budget setting
  ///
  /// Parameters:
  ///
  /// int recurringMonth: the number of months to set the budget (recurring)
  ///
  /// double amount: the amount to set the budget
  ///
  /// Returns: void
  void _handleBudgetSettingsSubmit(int recurringMonth, double amount, bool isPreviousMonth) {
    if (recurringMonth > 0) {
      setState(() {
        _recurringMonths = recurringMonth;
        _message = 'Recurrence: $_recurringMonths months';
        isRecurringBudget = true;
      });
    } else {
      setState(() {
        isRecurringBudget = false;
        _message = "";
      });
    }
    if (amount >= 0) {
      setState(() {
        _currentAmount = amount.toStringAsFixed(
            amount.truncateToDouble() == amount ? 0 : 2);
        _numbers.clear();
        _numbers.add(_currentAmount);
        _lastButton = '✓';
      });
    }
  }

  // This method would be called by the input form buttons
  void _onButtonPressed(String buttonText) async { // Make the method async
    // Removed setState(() async {...}) as it's an anti-pattern.
    // Call setState where actual state changes happen.

    String lastChar = _currentAmount.substring(_currentAmount.length - 1);
    int inputLen = _currentAmount.length;
    int numLen = _numbers.length;

    if (buttonText == 'C') {
      setState(() {
        // clear the input
        _currentAmount = '0';
        _numbers.clear();
        _numbers.add('0');
      });

    } else if (buttonText == '<') {
      setState(() {
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
      });

    } else if (buttonText == '=') {
      setState(() {
        try {
          Expression exp = ShuntingYardParser().parse(_currentAmount);
          ContextModel cm = ContextModel();
          double evalResult = exp.evaluate(EvaluationType.REAL, cm);

          _currentAmount = evalResult.toStringAsFixed(
              evalResult.truncateToDouble() == evalResult
                  ? 0
                  : 2);

          if (_currentAmount == 'Infinity' || _currentAmount == 'NaN') {
            _currentAmount = '0';
            _numbers.clear();
            _numbers.add('0');
          } else {
            _numbers.clear();
            _numbers.add(_currentAmount);
          }

        } catch (e) {
          _currentAmount = '0';
          _numbers.clear();
          _numbers.add('0');
        }
      });

    } else if (buttonText == '✓') {
      if (double.parse(_currentAmount) <= 0 || double.parse(_currentAmount) > 999999999999.99) {
        setState(() {
          _showError = true;
          _currentAmount = '0';
          _numbers.clear();
          _numbers.add('0');
        });
        return;
      }
      if (_recurrenceType != RecurrenceType.none &&
          !_currDate.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Create Transactions?'),
                content: Text(
                    'Creating recurrence at the past will cause transactions to be created and update the recurrence.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onSubmit(
                        DateTime(_currDate.year, _currDate.month, _currDate.day),
                        double.parse(_currentAmount),
                        _noteController.text,
                        _recurringMonths,
                        _recurrenceType,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Create'),
                  ),
                ],
              );
            }
        );
      } else {
        widget.onSubmit(
          DateTime(_currDate.year, _currDate.month, _currDate.day),
          double.parse(_currentAmount),
          _noteController.text,
          _recurringMonths,
          _recurrenceType,
        );
      }
    } else if (buttonText == '\$') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Choose a currency'),
              children: _currencies.map((currency) =>
                  ListTile(
                      title: Text(currency.fullName),
                      onTap: () {
                        widget.onCurrencyUpdate(currency);
                        Navigator.pop(context);
                      }
                  )).toList(),
            );
          }
      );
    } else if (buttonText == 'budget') {

      int month = widget.defaultDate!.month; // Use currDate from state
      int year = widget.defaultDate!.year;   // Use currDate from state
      month = month == 1 ? 12 : month - 1;
      year = month == 12 ? year - 1 : year;

      double? lastBudget = await BudgetRepositories.instance.getBudget(month, year, widget.categoryId);

      if (!mounted) return;

      showModalBottomSheet(
          context: context,
          isDismissible: false,
          isScrollControlled: true, // Allows sheet to take more height if needed
          builder: (sheetContext) {
            return BudgetSettingsPage(
              expenseAsBudget: widget.expenseAsBudget,
              lastBudget: lastBudget,
              month: month,
              year: year,
              isRecurring: isRecurringBudget,
              mainCurrency: widget.mainCurrency,
              submitSettings: _handleBudgetSettingsSubmit,
              deleteBudget: widget.onDeleteBudget!,
              disabledDelete: widget.disabledBudgetDelete,
            );
          }
      );

    }else if (buttonText == 'calendar') {

      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColor.secondary,
          builder: (periodSheetContext) {
            return SafeArea(
              child: SingleChildScrollView(
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
                            CalendarSelectorHelper.selectDate(context, (date) {
                              setState(() {
                                _currDate = date;
                                _datePrefix = formatDate(_currDate, [DD]);// Update datePrefix
                                _message = '$_datePrefix, ${formatDate(_currDate, [dd, ' ', M, ' ', yyyy])}';
                              });
                              Navigator.pop(context);
                            });
                          },
                        ),

                        /// select recurrence
                        PeriodTile(
                          parentContext: context,
                          label: 'Recurrence',
                          selected: _recurrenceType.name.toUpperCase(),
                          isSelected: _recurrenceType != RecurrenceType.none,
                          icon: Icons.repeat,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    title: Text('Select Recurrence'),
                                    children: [
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            _recurrenceType = RecurrenceType.none;
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('None'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            _recurrenceType = RecurrenceType.daily;
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Daily'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            _recurrenceType = RecurrenceType.weekday;
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Weekday'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            _recurrenceType = RecurrenceType.weekend;
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Weekend'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            _recurrenceType = RecurrenceType.weekly;
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Weekly'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            _recurrenceType = RecurrenceType.monthly;
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Monthly'),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          setState(() {
                                            _recurrenceType = RecurrenceType.yearly;
                                          });
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Yearly'),
                                      ),
                                    ],
                                  );
                                }
                            );
                          },
                        ),

                        /// select yesterday
                        PeriodTile(
                          parentContext: context,
                          label: 'Yesterday',
                          isSelected: _datePrefix == 'Yesterday',
                          selected: formatDate(DateTime.now().subtract(const Duration(days: 1)), [dd, ' ', M, ' ', yyyy]),
                          icon: Icons.mode_night_rounded,
                          onPressed: () {
                            setState(() {
                              _currDate = DateTime.now().subtract(const Duration(days: 1));
                              _datePrefix = 'Yesterday';
                              _message = '$_datePrefix, ${formatDate(_currDate, [dd, ' ', M, ' ', yyyy])}';
                            });
                            Navigator.pop(context);
                          },
                        ),

                        /// select today
                        PeriodTile(
                          parentContext: context,
                          label: 'Today',
                          selected: formatDate(DateTime.now(), [dd, ' ', M, ' ', yyyy]),
                          isSelected: _datePrefix == 'Today',
                          icon: Icons.sunny,
                          onPressed: () {
                            setState(() {
                              _currDate = DateTime.now();
                              _datePrefix = 'Today';
                              _message = '$_datePrefix, ${formatDate(_currDate, [dd, ' ', M, ' ', yyyy])}';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ]),
                ),
              ));
          }
      );

    } else if (_operators.contains(buttonText)) {
      // Logic for operators
      // ... (your existing operator handling logic)
      setState(() { // Wrap this block in setState
        if (_operators.contains(lastChar)) {
          if (buttonText == 'x') {
            buttonText = inputLen == 1 ? '0*' : '*';
          } else if (buttonText == '÷') {
            buttonText = inputLen == 1 ? '0/' : '/';
          }
          _currentAmount =
              _currentAmount.substring(0, _currentAmount.length - 1)
                  + buttonText;
        } else {
          if (buttonText == '÷') {
            _currentAmount += '/';
            _numbers.add("");
          }
          else if (buttonText == 'x') {
            _currentAmount += '*';
            _numbers.add("");
          }
          else if (buttonText == '-' || buttonText == '+') {
            if (_currentAmount == '0') {
              _currentAmount = buttonText;
              _numbers.clear();
              _numbers.add(buttonText);
            } else {
              _currentAmount += buttonText;
              _numbers.add("");
            }
          }
        }
      }); // End of setState for operator logic

    } else if (buttonText == '.') {
      setState(() { // Wrap this block in setState
        // Allow only one decimal point
        if (!_numbers[numLen - 1].contains('.')) {
          _currentAmount += ".";
          _numbers[numLen - 1] += ".";
        }
      }); // End of setState for decimal logic

    } else {
      setState(() { // Wrap this block in setState
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
      }); // End of setState for number logic
    }
    // Update _lastButton and _showError outside conditional setState blocks
    // to ensure they are always updated regardless of the button pressed
    if (mounted) { // Ensure widget is mounted before updating state
      setState(() {
        _lastButton = _numbers.length == 1 ? '✓' : '=';
        _showError = false;
      });
    }
  }
}
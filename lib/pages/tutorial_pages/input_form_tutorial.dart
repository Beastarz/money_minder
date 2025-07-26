import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';

import '../../components/tutorial/tutorial_text_box.dart';

class InputFormTutorial extends StatelessWidget {
  const InputFormTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: MediaQuery.of(context).size.width * 0.1),
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Transaction Input', style: TextStyle(fontSize: 24),)),
                TutorialImage(imagePath: 'assets/tutorial_pictures/input_sheet.jpg', title: "Transaction Input Form"),
                TutorialTextBox(prefix: '1.', body: 'From Account/Income Card - Tap to select a from account/income.'),
                TutorialTextBox(prefix: '2.', body: 'To Account/Expense Card - Tap to select a to account/expense.'),
                TutorialTextBox(prefix: '3.', body: 'Notes Field - Input your notes here.'),
                TutorialTextBox(prefix: '4.', body: 'Fast Notes - Select fast notes for your transaction.'),
                TutorialTextBox(prefix: '5.', body: 'Add New Fast Note Button - Create new fast notes'),
                TutorialTextBox(prefix: '6.', body: 'Math Operators - Calculate your transaction amount.'),
                TutorialTextBox(prefix: '7.', body: 'Number Pad - Input your transaction amount.'),
                TutorialTextBox(prefix: '8.', body: 'Clear Button - Clear your transaction amount.'),
                TutorialTextBox(prefix: '9.', body: 'Backspace Button - Delete last character.'),
                TutorialTextBox(prefix: '10.', body: 'Date/Period/Recurrence Selector - Select your transaction date/period/recurrence.'),
                TutorialTextBox(prefix: '11.', body: 'Currency Selector - Select your transaction currency.'),
                TutorialTextBox(prefix: '12.', body: 'Save Transaction Button - Create your new transaction.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/input_date_selector.jpg', title: 'Date/Period/Recurrence Selector'),
                TutorialTextBox(prefix: '1.', body: 'Date Selector - Tap to select a transaction date.'),
                TutorialTextBox(prefix: '2.', body: 'Recurrence Selector - Tap to set a recurrence for your transaction.'),
                TutorialTextBox(prefix: '3.', body: 'Date Selector--Yesterday - Tap to set your transaction date to yesterday.'),
                TutorialTextBox(prefix: '4.', body: 'Date Selector--Today - Tap to set your transaction date to today.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

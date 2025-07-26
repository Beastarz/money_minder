import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';

import '../../components/tutorial/tutorial_text_box.dart';

class SplitBillTutorial extends StatelessWidget {
  const SplitBillTutorial({super.key});

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
                Center(child: Text('Split Bill', style: TextStyle(fontSize: 24),)),
                TutorialImage(imagePath: 'assets/tutorial_pictures/split_bill.jpg', title: "Split Bill Page"),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Tap to close the online page.'),
                TutorialTextBox(prefix: '2.', body: 'Currency - Tap to select a currency.'),
                TutorialTextBox(prefix: '3.', body: 'Group Message - Input a message for this group.'),
                TutorialTextBox(prefix: '4.', body: 'Split Type - Tap to select a split type of this group (Custom, Even, Ratio).'),
                TutorialTextBox(prefix: '5.', body: 'Include Myself Option - Choose to include yourself in the group.'),
                TutorialTextBox(prefix: '6.', body: 'Total Amount Field - Input a total amount for this group if split type is Even or Ratio.'),
                TutorialTextBox(prefix: '7.', body: 'Recipient Amount Field - Input amount for this recipient if split type is Custom.'),
                TutorialTextBox(prefix: '8.', body: 'User Search - Tap to search for users.'),
                TutorialTextBox(prefix: '9.', body: 'Remove Button - Tap to remove this recipient.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

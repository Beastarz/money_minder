import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';
import 'package:money_minder/components/tutorial/tutorial_text_box.dart';

class TransactionTutorial extends StatelessWidget {
  const TransactionTutorial({super.key});

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
                Center(child: Text('Transactions Page', style: TextStyle(fontSize: 24),)),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/transactions_page.jpg', title: 'Transactions Page'),
                TutorialTextBox(prefix: '1.', body: 'Transactions Filter Button - Tap to navigate to transactions filter page.'),
                TutorialTextBox(prefix: '2.', body: 'Period Bar - Tap the left and right arrows to view transactions in different periods. Tap the calender button to change period settings.'),
                TutorialTextBox(prefix: '3.', body: 'Upcoming Transactions Drawer - Tap to open or collapse upcoming transactions.'),
                TutorialTextBox(prefix: '4.', body: 'Upcoming Transaction - Tap to view details of upcoming transaction.'),
                TutorialTextBox(prefix: '5.', body: 'Transaction - Tap to view details of transaction.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/transaction_detail.jpg', title: 'Transaction Detail Sheet'),
                TutorialTextBox(prefix: '1.', body: 'Edit Transaction Button - Tap to edit this transaction.'),
                TutorialTextBox(prefix: '2.', body: 'Delete Transaction Button - Tap to delete this transaction.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/transaction_future_detail.jpg', title: 'Upcoming Transaction Detail Sheet'),
                TutorialTextBox(prefix: '1.', body: 'Edit Upcoming Transaction Button - Tap to edit this upcoming transaction.'),
                TutorialTextBox(prefix: '2.', body: 'Delete Upcoming Transaction Button - Tap to delete this upcoming transaction.'),
                TutorialTextBox(prefix: '3.', body: 'Skip Recurrence Button - Tap to skip the current recurrence of this upcoming transaction.'),
                TutorialTextBox(prefix: '4.', body: 'Add Now Button - Tap to log this upcoming transaction now.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/transaction_filter.jpg', title: 'Transactions Filter Page'),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Tap to navigate back to the last page.'),
                TutorialTextBox(prefix: '2.', body: 'Apply Button - Apply the chosen transaction filters'),
                TutorialTextBox(prefix: '3.', body: 'Filters - Select the filters you want to apply.'),
                TutorialTextBox(prefix: '4.', body: 'Clear Button - Clear all filters.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';
import 'package:money_minder/components/tutorial/tutorial_text_box.dart';

class AccountTutorial extends StatelessWidget {
  const AccountTutorial({super.key});

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
              Center(child: Text('Accounts Page', style: TextStyle(fontSize: 24),)),
              Divider(),
              TutorialImage(imagePath: 'assets/tutorial_pictures/main_account.jpg', title: 'Accounts Page',),
              TutorialTextBox(prefix: '1.', body: 'Add new account button - Tap to navigate to add account page.'),
              TutorialTextBox(prefix: '2.', body: 'Account types tab - Navigate through regular, savings, and debts by clicking on these tabs.'),
              TutorialTextBox(prefix: '3.', body: 'Account tile - Tap to see more details on your account.'),
              Divider(),
              TutorialImage(imagePath: 'assets/tutorial_pictures/account_detail.jpg', title: 'Account Detail Sheet'),
              TutorialTextBox(prefix: '1.', body: 'Receive button - Tap to receive money from other account to this account.'),
              TutorialTextBox(prefix: '2.', body: 'Transfer button - Tap to transfer money from this account to another account.'),
              TutorialTextBox(prefix: '3.', body: 'Transactions button - Tap to see transactions filtered by this account.'),
              TutorialTextBox(prefix: '4.', body: 'Edit account button - Tap to edit this account.'),
              TutorialTextBox(prefix: '5.', body: 'Set Main button - Tap to set this account as main account.'),
              Divider(),
              TutorialImage(imagePath: 'assets/tutorial_pictures/add_account.jpg', title: 'Add Account Page'),
              TutorialTextBox(prefix: '1.', body: 'Close button - Tap to navigate back to the last page.'),
              TutorialTextBox(prefix: '2.', body: 'Create button - Tap to create a new account if all required fields are filled.'),
              TutorialTextBox(prefix: '3.', body: 'Name field - Input your new account name here.'),
              TutorialTextBox(prefix: '4.', body: 'Account Icon - Tap to select an icon and a color for your new account.'),
              TutorialTextBox(prefix: '5.', body: 'Type field - Select the type of your new account.'),
              TutorialTextBox(prefix: '6.', body: 'Account Currency field - Select the currency of your new account.'),
              TutorialTextBox(prefix: '7.', body: 'Description field - Input a description for your new account, this field is optional.'),
              TutorialTextBox(prefix: '8.', body: 'Account balance field- Input the starting balance for your account.'),
              TutorialTextBox(prefix: '9.', body: 'Include in total balance option - Choose if you want to include this account in the total balance.'),
              Divider(),
              TutorialImage(imagePath: 'assets/tutorial_pictures/edit_account.jpg', title: 'Edit Account Page'),
              TutorialTextBox(prefix: '1.', body: 'Edit button - Tap to save your edit on this account.'),
              TutorialTextBox(prefix: '2.', body: 'Delete button - Tap delete this account, all relevant transactions will also be deleted.'),
              Divider(),
            ],
          ),
        ),
      )
    );
  }
}

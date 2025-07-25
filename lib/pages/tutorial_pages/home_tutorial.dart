import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';
import 'package:money_minder/components/tutorial/tutorial_text_box.dart';

class HomeTutorial extends StatelessWidget {
  const HomeTutorial({super.key});

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
                Center(child: Text('Money Minder Tutorial', style: TextStyle(fontSize: 24),)),
                SizedBox(height: 8,),
                Center(child: Text('App Bar & Bottom Bar', style: TextStyle(fontSize: 24),)),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/appbar.jpg', title: 'App Bar'),
                TutorialTextBox(prefix: '1.', body: 'App drawer - Tap to open the app drawer for settings and profile.'),
                TutorialTextBox(prefix: '2.', body: 'Total account balance - Total balance of all included accounts. Tap to change the included accounts.'),
                TutorialTextBox(prefix: '3.', body: 'Online mode button - Tap to navigate to Money Minder Online.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/bottom_bar.jpg', title: 'Bottom Bar'),
                TutorialTextBox(prefix: '1.', body: 'Accounts - Tap to navigate to accounts page.'),
                TutorialTextBox(prefix: '2.', body: 'Categories - Tap to navigate to categories page.'),
                TutorialTextBox(prefix: '3.', body: 'Transactions - Tap to navigate to Transactions page.'),
                TutorialTextBox(prefix: '4.', body: 'Statistics - Tap to navigate to Statistics page.'),
                Divider(),
              ],
            ),
          ),
        )
    );;
  }
}

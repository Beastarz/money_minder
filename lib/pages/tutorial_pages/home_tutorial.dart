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
                SizedBox(height: 8,),
                Center(child: Text('Money Minder Tutorial', style: TextStyle(fontSize: 26),)),
                SizedBox(height: 8,),
                Center(child: Text('App Bar & Bottom Bar', style: TextStyle(fontSize: 24),)),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/appbar.jpg', title: 'App Bar'),
                TutorialTextBox(prefix: '1.', body: 'App Drawer - Tap to open the app drawer for settings and profile.'),
                TutorialTextBox(prefix: '2.', body: 'Total Account Balance - Total balance of all included accounts. Tap to set account filters.'),
                TutorialTextBox(prefix: '3.', body: 'Online Mode Button - Tap to navigate to Money Minder Online.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/bottom_bar.jpg', title: 'Bottom Bar'),
                TutorialTextBox(prefix: '1.', body: 'Accounts - Tap to navigate to accounts page.'),
                TutorialTextBox(prefix: '2.', body: 'Categories - Tap to navigate to categories page.'),
                TutorialTextBox(prefix: '3.', body: 'Transactions - Tap to navigate to Transactions page.'),
                TutorialTextBox(prefix: '4.', body: 'Statistics - Tap to navigate to Statistics page.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/drawer.png', title: 'App Drawer'),
                TutorialTextBox(prefix: '1.', body: 'Profile - Tap to navigate to profile page.'),
                TutorialTextBox(prefix: '2.', body: 'Currency Settings - Tap to navigate to currency settings page.'),
                TutorialTextBox(prefix: '3.', body: 'Notifications Settings - Tap to navigate to notifications settings page.'),
                TutorialTextBox(prefix: '4.', body: 'Passcode Settings - Tap to navigate to passcode settings page.'),
                TutorialTextBox(prefix: '5.', body: 'Manage Data - Tap to navigate to manage data page.'),
                TutorialTextBox(prefix: '6.', body: 'Tutorial - Tap to navigate to tutorial page.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/drawer_profile.png', title: 'Profile Page'),
                TutorialTextBox(prefix: '1.', body: 'Username - Your username. You cannot change your username.'),
                TutorialTextBox(prefix: '2.', body: 'Phone Number - Your phone number. Tap on the edit button to edit your phone number.'),
                TutorialTextBox(prefix: '3.', body: 'Sign Out Button - Tap to sign out of your account.'),
                TutorialTextBox(prefix: '4.', body: 'Delete Account Button - Tap to delete your account. This action is irreversible.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/drawer_currency.jpg', title: 'Currency Settings Sheet'),
                TutorialTextBox(prefix: '  ', body: 'Main Currency - Tap to select your main currency.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/drawer_notification.jpg', title: 'Notifications Settings Sheet'),
                TutorialTextBox(prefix: '  ', body: 'Notifications - Tap to set or edit your reminder notification.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/drawer_passcode.jpg', title: 'Passcode Settings Page'),
                TutorialTextBox(prefix: '  ', body: 'Passcode - Tap to set or edit your passcode.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/drawer_data.jpg', title: 'Manage Data Sheet'),
                TutorialTextBox(prefix: '1.', body: 'Import Data - Tap to import data from CSV file.'),
                TutorialTextBox(prefix: '2.', body: 'Export Data - Tap to export data to CSV file.'),
                TutorialTextBox(prefix: '3.', body: 'Backup Data - Tap to backup data to cloud.'),
                TutorialTextBox(prefix: '4.', body: 'Restore Data - Tap to restore data from cloud.'),
                TutorialTextBox(prefix: '5.', body: 'Reset Data - Tap to rest all data.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

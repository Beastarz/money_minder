import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';

import '../../components/tutorial/tutorial_text_box.dart';

class ContactsTutorial extends StatelessWidget {
  const ContactsTutorial({super.key});

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
                Center(child: Text('Money Minder Online', style: TextStyle(fontSize: 24),)),
                TutorialImage(imagePath: 'assets/tutorial_pictures/contacts.jpg', title: "Contacts Page"),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Tap to close the online page.'),
                TutorialTextBox(prefix: '2.', body: 'Menu - Tap to show menu of blocked list.'),
                TutorialTextBox(prefix: '3.', body: 'Search Bar - Search contacts. Start with @ to search for usernames in contacts.'),
                TutorialTextBox(prefix: '4.', body: 'Add Contacts - Tap to add new contacts.'),
                TutorialTextBox(prefix: '5.', body: 'Contact - Tap to view details of a contact.'),
                TutorialTextBox(prefix: '6.', body: 'Send Money - Tap to send money to this contact.'),
                TutorialTextBox(prefix: '7.', body: 'Ask Money - Tap to ask money to this contact.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/contact_find.png', title: 'Find User Page'),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Close the find user page.'),
                TutorialTextBox(prefix: '2.', body: 'Search Bar - Input the user\'s complete username.'),
                TutorialTextBox(prefix: '3.', body: 'Search - Tap to search users with their username.'),
                TutorialTextBox(prefix: '4.', body: 'User - Tap to add as a new contact.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/contact_add.png', title: 'Add Contact Sheet'),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Close the add contact sheet.'),
                TutorialTextBox(prefix: '2.', body: 'Contact Name Field - Input your contact name here.'),
                TutorialTextBox(prefix: '3.', body: 'Save Contact Button - Create your new contact.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/contact_edit.png', title: 'Contact Details Card'),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Tap to close this sheet.'),
                TutorialTextBox(prefix: '2.', body: 'Search User Button - Tap to change the user of this contact.'),
                TutorialTextBox(prefix: '3.', body: 'Phone Number - Tap the copy button to copy the phone number to clip board.'),
                TutorialTextBox(prefix: '4.', body: 'Nickname - Tap edit the nickname.'),
                TutorialTextBox(prefix: '5.', body: 'Save Button - Tap to save the edit of this contact.'),
                TutorialTextBox(prefix: '6.', body: 'Block Button - Tap to block this contact.'),
                TutorialTextBox(prefix: '7.', body: 'Delete Button - Tap to delete this contact.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

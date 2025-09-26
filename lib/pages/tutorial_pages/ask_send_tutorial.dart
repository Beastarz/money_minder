import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';

import '../../components/tutorial/tutorial_text_box.dart';

class SendAskTutorial extends StatelessWidget {
  const SendAskTutorial({super.key});

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
                Center(child: Text('Send/Ask Money', style: TextStyle(fontSize: 24),)),
                TutorialImage(imagePath: 'assets/tutorial_pictures/send_money.jpg', title: "Send/Ask Money Page"),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Tap to close this page.'),
                TutorialTextBox(prefix: '2.', body: 'Amount Field - Input the amount to send/ask.'),
                TutorialTextBox(prefix: '3.', body: 'Search User - Tap to search for users.'),
                TutorialTextBox(prefix: '4.', body: 'Currency - Tap to select a currency.'),
                TutorialTextBox(prefix: '5.', body: 'Message Field - Input a message for this request.'),
                TutorialTextBox(prefix: '6.', body: 'Send Button - Tap to send the request.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

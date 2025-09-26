import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';

import '../../components/tutorial/tutorial_text_box.dart';

class OnlineTutorial extends StatelessWidget {
  const OnlineTutorial({super.key});

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
                TutorialImage(imagePath: 'assets/tutorial_pictures/online.jpg', title: "Online Home Page"),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Tap to close the online page.'),
                TutorialTextBox(prefix: '2.', body: 'Contacts - Tap to open contacts page.'),
                TutorialTextBox(prefix: '3.', body: 'Manage Request - Tap to view sent and received requests.'),
                TutorialTextBox(prefix: '4.', body: 'Send Money - Tap to open send money page.'),
                TutorialTextBox(prefix: '5.', body: 'Ask Money - Tap to open ask money page.'),
                TutorialTextBox(prefix: '6.', body: 'Split Bill - Tap to open split bill page.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

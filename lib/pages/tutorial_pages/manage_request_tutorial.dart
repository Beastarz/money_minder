import 'package:flutter/material.dart';
import 'package:money_minder/components/tutorial/tutorial_image.dart';

import '../../components/tutorial/tutorial_text_box.dart';

class ManageRequestTutorial extends StatelessWidget {
  const ManageRequestTutorial({super.key});

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
                Center(child: Text('Manage Requests', style: TextStyle(fontSize: 24),)),
                TutorialImage(imagePath: 'assets/tutorial_pictures/manage_request.jpg', title: "Sent Request"),
                TutorialTextBox(prefix: '1.', body: 'Close Button - Tap to close this page.'),
                TutorialTextBox(prefix: '2.', body: 'Sent/Received Tab - Tap to switch between sent and received requests.'),
                TutorialTextBox(prefix: '3.', body: 'Request - Tap to view the details of a request.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/request_receive.png', title: "Received Request"),
                TutorialTextBox(prefix: '1.', body: 'Reject Button - Tap to reject this request.'),
                TutorialTextBox(prefix: '2.', body: 'Accept Button - Tap to accept this request.'),
                Divider(),
                TutorialImage(imagePath: 'assets/tutorial_pictures/request_detail.jpg', title: "Transaction Request Details"),
                TutorialTextBox(prefix: '1.', body: 'Copy Button - Tap to copy the phone number.'),
                TutorialTextBox(prefix: '2.', body: 'Create Transaction Button - Tap to create a transaction with this request.'),
                TutorialTextBox(prefix: '3.', body: 'Block Button - Tap to block this user.'),
                Divider(),
              ],
            ),
          ),
        )
    );
  }
}

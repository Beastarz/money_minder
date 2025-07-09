import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/online/user_contact.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/models/online/user.dart' as model;

import '../../../firestore_repositories/user_contacts_repositories.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key, required this.user, required this.onContactsReload,});

  final model.User user;
  final Future<void> Function() onContactsReload;

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _nickNameController = TextEditingController();
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.secondary
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              title: Text('Add Contact', style: TextStyle(fontSize:24, fontWeight: FontWeight.w500),),
              centerTitle: true,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                          'Username: @${widget.user.username}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Phone Number: @${widget.user.phoneNumber}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                    TextField(
                      controller: _nickNameController,
                      decoration: InputDecoration(
                        label: Text('Nickname'),
                        border: OutlineInputBorder()
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          if (_nickNameController.text.isEmpty) {
                            setState(() {
                              _message = 'Please enter a nickname';
                            });
                            return;
                          }
                          try {
                            await UserContactsRepositories.instance
                                .addUserContact(
                                FirebaseAuth.instance.currentUser!.uid,
                                widget.user.uid,
                                UserContact.insertAsMap(
                                    username: widget.user.username,
                                    phoneNumber: widget.user.phoneNumber,
                                    nickname: _nickNameController.text
                                ));
                            widget.onContactsReload();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            setState(() {
                              _message = 'Failed to add contact';
                            });
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
                        ),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Center(child: Text('Save', style: TextStyle(color: Colors.white),))
                        ),
                      ),
                    ),
                    _message.isEmpty ? SizedBox.shrink(): Text(_message, style: TextStyle(color: Colors.red),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:money_minder/models/user_contact.dart';
import 'package:money_minder/repositories/user_contacts_repositories.dart';
import 'package:money_minder/style/app_color.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key, required this.username, required this.onContactsReload,});

  final String username;
  final Future<void> Function() onContactsReload;

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _nickNameController = TextEditingController();
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
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
                          'Username: @${widget.username}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
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
                          await UserContactsRepositories.instance.addUserContact(
                              UserContact.insertAsMap(
                                username: widget.username,
                                nickname: _nickNameController.text
                          ));
                          widget.onContactsReload();
                          if (context.mounted) {
                            Navigator.pop(context);
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

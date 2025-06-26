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
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Contact'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3,),
                  Flexible(
                    child: Text(
                        'Username: @${widget.username}',
                        style: TextStyle(
                          fontSize: 18
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

                  TextButton(
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
                        Navigator.pop(context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(AppColor.secondary),
                    ),
                    child: Text('Save'),
                  ),
                  _message.isEmpty ? SizedBox.shrink(): Text(_message, style: TextStyle(color: Colors.red),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

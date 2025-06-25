import 'package:flutter/material.dart';
import 'package:money_minder/components/contacts/username_search_page.dart';
import 'package:money_minder/models/user_contact.dart';
import 'package:money_minder/repositories/user_contacts_repositories.dart';
import 'package:money_minder/style/app_color.dart';

class EditContactPage extends StatefulWidget {
  const EditContactPage({super.key, required this.contact, required this.onContactsReload, });

  final UserContact contact;
  final Future<void> Function() onContactsReload;

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final TextEditingController _nickNameController = TextEditingController();
  String _username = '';
  String _message = '';

  @override
  void initState() {
    super.initState();
    _username = widget.contact.username;
    _nickNameController.text = widget.contact.nickname;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Contact'),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.28,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Username: @$_username',
                          style: TextStyle(
                              fontSize: 16
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 24,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UsernameSearchPage(
                              onUsernameSelection: (username) {
                                setState(() {
                                  _username = username;
                                });
                              },
                            ))
                          );
                        },
                        icon: Icon(Icons.search)
                      )
                    ],
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
                      await UserContactsRepositories.instance.updateUserContact(
                          widget.contact.copyWith(
                            username: _username,
                            nickname: _nickNameController.text
                          ));
                       widget.onContactsReload();

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(AppColor.secondary),
                    ),
                    child: Text('Save'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(AppColor.secondary),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Contact'),
                          content: Text('Are you sure you want to delete this contact?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                UserContactsRepositories.instance.deleteUserContact(widget.contact.id);
                                widget.onContactsReload();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('Delete', style: TextStyle(color: Colors.red),),
                            ),
                          ],
                        )
                      );
                    },
                    child: Text('Delete', style: TextStyle(color: Colors.red),)
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

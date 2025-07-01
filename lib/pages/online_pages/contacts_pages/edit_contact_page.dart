import 'package:flutter/material.dart';
import 'package:money_minder/models/user_contact.dart';
import 'package:money_minder/repositories/blocked_users_repositories.dart';
import 'package:money_minder/repositories/user_contacts_repositories.dart';
import 'package:money_minder/style/app_color.dart';

import '../../../components/search_users/username_search_page.dart';

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
    Widget blockButton = TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColor.secondary),
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Block User'),
                content: Text('Are you sure you want to block @$_username?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      UserContactsRepositories.instance.blockContact(widget.contact.username);
                      BlockedUsersRepositories.instance.addBlockedUser(_username);
                      widget.onContactsReload();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text('Block', style: TextStyle(color: Colors.red),),
                  ),
                ],
              )
          );
        },
        child: Text('Block', style: TextStyle(color: Colors.red),)
    );

    Widget unblockButton = TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColor.secondary),
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Unblock User'),
                content: Text('Are you sure you want to unblock @$_username?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      UserContactsRepositories.instance.blockContact(widget.contact.username);
                      BlockedUsersRepositories.instance.addBlockedUser(_username);
                      widget.onContactsReload();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text('Unblock', style: TextStyle(color: Colors.red),),
                  ),
                ],
              )
          );
        },
        child: Text('Unblock', style: TextStyle(color: Colors.red),)
    );

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Contact'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Username: @$_username${widget.contact.isBlocked ? ' (Blocked)' : ''}',
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
                    widget.contact.isBlocked ? unblockButton : blockButton,
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
      ),
    );
  }
}

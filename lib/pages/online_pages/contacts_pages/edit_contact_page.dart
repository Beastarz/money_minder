import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/user_contact.dart';
import 'package:money_minder/repositories/blocked_users_repositories.dart';
import 'package:money_minder/style/app_color.dart';

import '../../../components/search_users/username_search_page.dart';
import '../../../firestore_repositories/user_contacts_repositories.dart';

class EditContactPage extends StatefulWidget {
  const EditContactPage({super.key, required this.contact, required this.onContactsReload, });

  final UserContact contact;
  final Future<void> Function() onContactsReload;

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final TextEditingController _nickNameController = TextEditingController();
  String myUid = FirebaseAuth.instance.currentUser!.uid;
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
          backgroundColor: WidgetStateProperty.all(Colors.red),
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
                    onPressed: () async {
                      await UserContactsRepositories.instance.blockContact(myUid, widget.contact.username);
                      await BlockedUsersRepositories.instance.addBlockedUser(_username);
                      widget.onContactsReload();
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Block', style: TextStyle(color: Colors.red),),
                  ),
                ],
              )
          );
        },
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Center(child: Text('Block', style: TextStyle(color: Colors.white),))
        )
    );

    Widget unblockButton = TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.red),
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
                    onPressed: () async {
                      await UserContactsRepositories.instance.unblockContact(myUid, widget.contact.username);
                      await BlockedUsersRepositories.instance.deleteBlockedUser(_username);
                      widget.onContactsReload();
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Unblock', style: TextStyle(color: Colors.red),),
                  ),
                ],
              )
          );
        },
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Center(child: Text('Unblock', style: TextStyle(color: Colors.white),))
        )
    );

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
              title: Text('Edit Contact', style: TextStyle(fontSize:24, fontWeight: FontWeight.w500),),
              centerTitle: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  spacing: 16,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Username: @$_username${widget.contact.isBlocked ? ' (Blocked)' : ''}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600
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
                            myUid,
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
                        backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Center(child: Text('Save', style: TextStyle(color: Colors.white),))
                      ),
                    ),
                    widget.contact.isBlocked ? unblockButton : blockButton,
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
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
                                onPressed: () async {
                                  await UserContactsRepositories.instance.deleteUserContact(myUid, widget.contact.id);
                                  widget.onContactsReload();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Delete', style: TextStyle(color: Colors.red),),
                              ),
                            ],
                          )
                        );
                      },
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Center(child: Text('Delete', style: TextStyle(color: Colors.white),))
                      )
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

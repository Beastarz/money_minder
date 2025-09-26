import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_minder/firestore_repositories/blocked_users_repositories.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/models/online/user.dart' as model;
import 'package:money_minder/style/app_size.dart';

import '../../../components/search_users/username_search_page.dart';
import '../../../firestore_repositories/user_contacts_repositories.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key, this.onContactsReload});

  final Function()? onContactsReload;

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  List<String> _blockedUsers = [];
  List<String> _filteredUsers = [];
  String _selectedUsername = '';
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBlockedUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchBlockedUsers() async {
    final res = await BlockedUsersRepositories.instance.getBlockedUsernames(myUid);
    setState(() {
      _blockedUsers = res;
      _filteredUsers = res;
    });
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _filteredUsers = _blockedUsers
          .where((username) =>
          username.toLowerCase().startsWith(query)).toList();
    });
  }

  void _onSelectUsername(model.User user) {
    setState(() {
      _selectedUsername = user.username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blocked Users', style: TextStyle(fontSize: 16.sp),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              spacing: 4.h,
              children: <Widget>[
                SearchBar(
                  controller: _searchController,
                  leading: Icon(Icons.search, size: AppSize.bigIcon.sp,),
                  hintText: 'Search @username or Nickname',
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16.sp)),
                  backgroundColor: WidgetStateProperty.all(AppColor.secondary),
                  elevation: WidgetStateProperty.all(2),
                ),
                ListTile(
                    leading: Icon(Icons.add, size: AppSize.bigIcon.sp,),
                    title: Text('Add a user', style: TextStyle(fontSize: 16.sp),),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UsernameSearchPage(onUsernameSelection: _onSelectUsername)));
                    }
                ),
                _selectedUsername.isEmpty ? SizedBox.shrink(): ListTile(
                  leading: SizedBox(),
                  minLeadingWidth: 8,
                  tileColor: AppColor.secondary,
                  title: Text(
                    _selectedUsername,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedUsername = '';
                            });
                          },
                          color: Colors.redAccent,
                          icon: Icon(Icons.close, size: AppSize.bigIcon.sp,)
                      ),
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Unblock User'),
                                  content: Text('Are you sure you want to block @$_selectedUsername?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await BlockedUsersRepositories.instance.addBlockedUser(myUid, _selectedUsername);
                                        await UserContactsRepositories.instance.blockContact(myUid, _selectedUsername);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        _fetchBlockedUsers();
                                        if (widget.onContactsReload != null) {
                                          widget.onContactsReload!();
                                        }
                                        setState(() {
                                          _selectedUsername = '';
                                        });
                                      },
                                      child: Text('Block', style: TextStyle(color: Colors.red),),
                                    ),
                                  ],
                                )
                            );
                          },
                          color: Colors.green,
                          icon: Icon(Icons.check, size: AppSize.bigIcon.sp,)
                      ),
                    ],
                  ),
                )
              ] + _filteredUsers.map((username) {
                return ListTile(
                  leading: SizedBox(),
                  minLeadingWidth: 8,
                  title: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Unblock User'),
                                  content: Text('Are you sure you want to unblock @$username?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await BlockedUsersRepositories.instance.deleteBlockedUser(myUid, username);
                                        await UserContactsRepositories.instance.unblockContact(myUid, username);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        _fetchBlockedUsers();
                                        if (widget.onContactsReload != null) {
                                          widget.onContactsReload!();
                                        }
                                      },
                                      child: Text('Unblock', style: TextStyle(color: Colors.red),),
                                    ),
                                  ],
                                )
                            );
                          },
                          icon: Icon(Icons.close, size: AppSize.bigIcon.sp,)
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

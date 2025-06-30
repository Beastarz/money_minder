import 'package:flutter/material.dart';
import 'package:money_minder/repositories/blocked_users_repositories.dart';
import 'package:money_minder/style/app_color.dart';

import '../../../components/search_users/username_search_page.dart';
import '../../../repositories/user_contacts_repositories.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBlockedUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchBlockedUsers() async {
    final res = await BlockedUsersRepositories.instance.getBlockedUsernames();
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

  void _onSelectUsername(String username) {
    setState(() {
      _selectedUsername = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Blocked Users'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 4,
              children: <Widget>[
                SearchBar(
                  controller: _searchController,
                  leading: Icon(Icons.search),
                  hintText: 'Search @username or Nickname',
                  backgroundColor: WidgetStateProperty.all(AppColor.secondary),
                  elevation: WidgetStateProperty.all(2),
                ),
                ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add a user'),
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
                          icon: Icon(Icons.close)
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
                                      onPressed: () {
                                        BlockedUsersRepositories.instance.addBlockedUser(_selectedUsername);
                                        UserContactsRepositories.instance.deleteUserContactByUsername(_selectedUsername);
                                        _fetchBlockedUsers();
                                        widget.onContactsReload;
                                        Navigator.pop(context);
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
                          icon: Icon(Icons.check,)
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
                                      onPressed: () {
                                        BlockedUsersRepositories.instance.deleteBlockedUser(username);
                                        Navigator.pop(context);
                                        _fetchBlockedUsers();
                                      },
                                      child: Text('Delete', style: TextStyle(color: Colors.red),),
                                    ),
                                  ],
                                )
                            );
                          },
                          icon: Icon(Icons.close)
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

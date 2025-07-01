import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/add_contact_page.dart';
import 'package:money_minder/style/app_color.dart';

import '../../repositories/blocked_users_repositories.dart';

class UsernameSearchPage extends StatefulWidget {
  const UsernameSearchPage({super.key, this.onContactsReload, this.onUsernameSelection, this.enableBlockedUserSearch = false});

  final void Function(String)? onUsernameSelection;
  final Future<void> Function()? onContactsReload;
  final bool enableBlockedUserSearch;

  @override
  State<UsernameSearchPage> createState() => _UsernameSearchPageState();
}

class _UsernameSearchPageState extends State<UsernameSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _usernames = [];
  List<String> _blockedUsers = [];
  String _myUsername = '';
  String message = 'Search for users!';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.enableBlockedUserSearch) {
      _fetchBlockedUsers();
    }
    _fetchMyUsername();
  }
  void _fetchMyUsername() async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    String? res = await UsersRepositories.instance.getUsername(user.uid);
    if (res != null) {
      setState(() {
        _myUsername = res;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void _fetchUsernames(String prefix) async {
    if (prefix.isEmpty) {
      setState(() {
        _usernames = [];
        message = 'Search for users!';
      });
      return;
    }
    if (prefix.startsWith('@')) {
      prefix = prefix.substring(1);
    }
    setState(() {
      isLoading = true;
    });
    final res = await UsersRepositories.instance.getUsernameByPrefix(prefix);
    setState(() {
      _usernames = res;
      isLoading = false;
    });
  }

  void _fetchBlockedUsers() async {
    final res = await BlockedUsersRepositories.instance.getBlockedUsernames();
    setState(() {
      _blockedUsers = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    _usernames = _usernames.where((name) => name != _myUsername && !_blockedUsers.contains(name)).toList();
    _usernames.sort();
    if (_usernames.isEmpty) {
      message = 'No users found';
    } else {
      message = '';
    }
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Find User'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                SearchBar(
                  controller: _searchController,
                  leading: Icon(Icons.search),
                  hintText: 'Search for a username',
                  backgroundColor: WidgetStateProperty.all(AppColor.secondary),
                  elevation: WidgetStateProperty.all(2),
                  trailing: [
                    isLoading ? CircularProgressIndicator() : IconButton(
                      icon: Icon(Icons.check_circle),
                      onPressed: () {
                        _fetchUsernames(_searchController.text);
                      },
                    ),
                  ]
                ),
                SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: AppColor.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _usernames.isEmpty ? ListTile(title: Text(message),) :
                    Column(
                      children: _usernames.map((username) =>
                          ListTile(
                            title: Text('@$username'),
                            onTap: () {
                              if (widget.onUsernameSelection != null) {
                                widget.onUsernameSelection!(username);
                                Navigator.pop(context);
                                return;
                              }
                              if (widget.onContactsReload != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddContactPage(username: username,
                                        onContactsReload: widget.onContactsReload!,))
                                );
                              }
                            },
                          )).toList(),
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

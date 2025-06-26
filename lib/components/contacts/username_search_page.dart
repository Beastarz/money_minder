import 'package:flutter/material.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/add_contact_page.dart';
import 'package:money_minder/style/app_color.dart';

class UsernameSearchPage extends StatefulWidget {
  const UsernameSearchPage({super.key, this.onContactsReload, this.onUsernameSelection});

  final void Function(String)? onUsernameSelection;
  final Future<void> Function()? onContactsReload;

  @override
  State<UsernameSearchPage> createState() => _UsernameSearchPageState();
}

class _UsernameSearchPageState extends State<UsernameSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _usernames = [];
  String message = 'Search for users!';
  bool isLoading = false;

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
      if (_usernames.isEmpty) {
        message = 'No users found';
      } else {
        message = '';
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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

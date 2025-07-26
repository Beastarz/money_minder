import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/firestore_repositories/users_repositories.dart';
import 'package:money_minder/models/online/user_contact.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/blocked_users_page.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/models/online/user.dart' as model;

import '../../../firestore_repositories/user_contacts_repositories.dart';

class ContactUserSearchPage extends StatefulWidget {
  const ContactUserSearchPage({super.key, required this.onUserSelection,});

  final Function(model.User) onUserSelection;

  @override
  State<ContactUserSearchPage> createState() => _ContactUserSearchPageState();
}

class _ContactUserSearchPageState extends State<ContactUserSearchPage> {
  List<UserContact> _contacts = [];
  List<UserContact> _filteredContacts = [];
  bool showSearchTile = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _fetchContacts() async {
    final res = await UserContactsRepositories.instance.getUserContact(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _contacts = res;
      _filteredContacts = _contacts;
    });
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _contacts;
      });
      return;
    }
    if (query.startsWith('@')) {
      if (query.length >= 7) {
        setState(() {
          showSearchTile = true;
        });
      } else {
        setState(() {
          showSearchTile = false;
        });
      }
      query = query.substring(1);
      setState(() {
        _filteredContacts = _contacts
            .where((contact) =>
            contact.username.toLowerCase().startsWith(query)).toList();
      });
    } else {
      setState(() {
        _filteredContacts = _contacts
            .where((contact) =>
            contact.nickname.toLowerCase().startsWith(query)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _filteredContacts.sort((contact, other) => contact.nickname.compareTo(other.nickname));
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search user'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(1, 0, 0, 0),
                    items: [
                      PopupMenuItem(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BlockedUsersPage(onContactsReload: _fetchContacts,))
                          );
                        },
                        child: Text('Blocked Users'),
                      ),
                    ]
                );
              },
              icon: Icon(Icons.more_vert),
            ),
          ],
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
                !showSearchTile ? Container() :
                Card(
                  color: AppColor.secondary,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: ListTile(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Search user '),
                          Flexible(child: Text(_searchController.text.toLowerCase(), style: TextStyle(fontWeight: FontWeight.w600),))
                        ],
                      ),
                      onTap: () async {
                        model.User? result = await UsersRepositories.instance.getUserByUsername(_searchController.text.substring(1));
                        if (context.mounted) {
                          if (result == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('No user found!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK'),
                                    )
                                  ],
                                );
                              }
                            );
                          } else {
                            Navigator.pop(context);
                            widget.onUserSelection(result);
                          }
                        }
                      },
                    ),
                  ),
                ),
                ListTile(
                  leading: SizedBox(),
                  minLeadingWidth: 8,
                  title: Text('non_user'),
                  subtitle: Text('select this if user are not registered'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onUserSelection(model.User.nonUser);
                  },
                )
              ] + _filteredContacts.map((contact) {
                return ListTile(
                  leading: SizedBox(),
                  minLeadingWidth: 8,
                  title: Text(
                    contact.nickname,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '@${contact.username}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onUserSelection(contact.toUserModel());
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

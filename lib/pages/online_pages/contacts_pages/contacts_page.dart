import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/models/online/user_contact.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/add_contact_page.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/blocked_users_page.dart';
import 'package:money_minder/pages/online_pages/contacts_pages/edit_contact_page.dart';
import 'package:money_minder/pages/online_pages/request_pages/ask_money_request.dart';
import 'package:money_minder/pages/online_pages/request_pages/send_money_page.dart';
import 'package:money_minder/style/app_color.dart';
import 'package:money_minder/models/online/user.dart' as model;

import '../../../components/search_users/username_search_page.dart';
import '../../../firestore_repositories/user_contacts_repositories.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<UserContact> _contacts = [];
  List<UserContact> _filteredContacts = [];
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

  void _onUsernameSelection(model.User username) {
    showDialog(
        context: context,
        builder: (context) {
          return AddContactPage(user: username, onContactsReload: _fetchContacts);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    _filteredContacts.sort((contact, other) => contact.nickname.compareTo(other.nickname));
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Contacts'),
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
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add Contacts'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UsernameSearchPage(onUsernameSelection: _onUsernameSelection)));
                  }
                ),
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
                        showDialog(
                            context: context,
                            builder: (context) {
                              return EditContactPage(contact: contact, onContactsReload: _fetchContacts);
                            }
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SendMoneyPage(defaultUser: contact.toUserModel(),)));
                              },
                              icon: Icon(Icons.upload_outlined, color: Colors.green[800],)
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AskMoneyPage(defaultUser: contact.toUserModel(),)));
                              },
                              icon: Icon(Icons.download_outlined, color: Colors.red[800],)
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

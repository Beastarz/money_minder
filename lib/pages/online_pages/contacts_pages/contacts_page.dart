import 'package:flutter/material.dart';
import 'package:money_minder/components/contacts/username_search_page.dart';
import 'package:money_minder/models/user_contact.dart';
import 'package:money_minder/style/app_color.dart';

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
    fetchContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> fetchContacts() async {
    // final res = await UserContactsRepositories.instance.getUserContact();
    setState(() {
      _contacts = [UserContact.fromMap(
        {
          "id": 1,
          "username": "username",
          "nickname": "nickname",
        }
      ), UserContact.fromMap(
          {
            "id": 2,
            "username": "username2",
            "nickname": "nickname2",
          }
      )];
      _filteredContacts = _contacts;
    });
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
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
    _filteredContacts.sort((contact, other) => contact.nickname.compareTo(other.nickname));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
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
                title: Text('Add Contacts'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UsernameSearchPage(onContactsReload: fetchContacts)));
                }
              ),
            ] + _filteredContacts.map((contact) {
                  return ListTile(
                    leading: SizedBox(),
                    minLeadingWidth: 8,
                    title: Text(contact.nickname),
                    subtitle: Text('@${contact.username}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.upload_outlined, color: Colors.green[800],)
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.download_outlined, color: Colors.red[800],)
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.edit_outlined)
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

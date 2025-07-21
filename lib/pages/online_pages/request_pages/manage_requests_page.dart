import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/request/request_list_tile.dart';
import 'package:money_minder/firestore_repositories/blocked_users_repositories.dart';
import 'package:money_minder/firestore_repositories/user_contacts_repositories.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user_contact.dart';
import 'package:money_minder/utils/loading_screen.dart';

import '../../../firestore_repositories/transaction_request_repositories.dart';

class ManageRequestsPage extends StatefulWidget {
  const ManageRequestsPage({super.key, required this.onReload});

  final void Function() onReload;

  @override
  State<ManageRequestsPage> createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> {
  List<UserContact> _contacts = [];
  List<String> _blockedList = [];
  List<TransactionRequest> _receivedRequest = [];
  List<TransactionRequest> _sentRequest = [];

  bool _isLoading = false;

  void _loadRequests() async {
    setState(() {
      _isLoading = true;
    });
    final String myUid = FirebaseAuth.instance.currentUser!.uid;
    final contacts = await UserContactsRepositories.instance.getUserContact(myUid);
    final blockedList = await BlockedUsersRepositories.instance.getBlockedUsernames(myUid);
    final receivedRequest = await TransactionRequestRepositories.instance.getReceivedTransactionRequests(myUid);
    final sentRequest = await TransactionRequestRepositories.instance.getSentTransactionRequests(myUid);
    receivedRequest.removeWhere((request) => blockedList.contains(request.sender.username));
    setState(() {
      _contacts = contacts;
      _blockedList = blockedList;
      _receivedRequest = receivedRequest;
      _sentRequest = sentRequest;
      _isLoading = false;
    });
  }

  void _onUserBlocked(String username) {
    setState(() {
      _receivedRequest.removeWhere((request) => request.sender.username == username);
      _blockedList.add(username);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    Widget receivedPage = _receivedRequest.isEmpty ? Center(child: Text('Empty'),) :
    ListView(
      children:  _receivedRequest.map((request) {
        String? nickname;
        for (final contact in _contacts) {
          if (contact.uid == request.sender.uid) {
            nickname = contact.nickname;
            break;
          }
        }

        return RequestListTile(
          transactionRequest: request,
          displayName: nickname ?? '@${request.sender.username}',
          isSender: false,
          onReload: widget.onReload,
          onUserBlocked: _onUserBlocked,
        );
      }).toList(),
    );

    Widget sentPage = _sentRequest.isEmpty ? Center(child: Text('Empty'),) :
    ListView(
      children: _sentRequest.map((request) {
        String? nickname;
        for (final contact in _contacts) {
          if (contact.uid == request.receiver.uid) {
            nickname = contact.nickname;
            break;
          }
        }
        return RequestListTile(
          transactionRequest: request,
          displayName: nickname ?? '@${request.receiver.username}',
          isSender: true,
          onReload: widget.onReload,
          onUserBlocked: _onUserBlocked,
        );

      }).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Requests'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: TabBar(
              tabs: [
                Tab(text: 'Received'),
                Tab(text: 'Sent'),
              ]
            ),
            body: TabBarView(
              children: _isLoading ? [LoadingScreen(), LoadingScreen()] :
              [
                receivedPage,
                sentPage,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

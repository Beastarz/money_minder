import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_minder/components/request/request_list_tile.dart';
import 'package:money_minder/firestore_repositories/user_contacts_repositories.dart';
import 'package:money_minder/models/online/transaction_request.dart';
import 'package:money_minder/models/online/user_contact.dart';
import 'package:money_minder/utils/loading_screen.dart';

import '../../../firestore_repositories/transaction_request_repositories.dart';

class ManageRequestsPage extends StatefulWidget {
  const ManageRequestsPage({super.key});

  @override
  State<ManageRequestsPage> createState() => _ManageRequestsPageState();
}

class _ManageRequestsPageState extends State<ManageRequestsPage> {
  List<UserContact> _contacts = [];
  List<TransactionRequest> _receivedRequest = [];
  List<TransactionRequest> _sentRequest = [];

  bool _isLoading = false;

  void _loadRequests() async {
    setState(() {
      _isLoading = true;
    });
    final contacts = await UserContactsRepositories.instance.getUserContact(FirebaseAuth.instance.currentUser!.uid);
    final receivedRequest = await TransactionRequestRepositories.instance.getReceivedTransactionRequests(FirebaseAuth.instance.currentUser!.uid);
    final sentRequest = await TransactionRequestRepositories.instance.getSentTransactionRequests(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _contacts = contacts;
      _receivedRequest = receivedRequest;
      _sentRequest = sentRequest;
      _isLoading = false;
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
        return RequestListTile(transactionRequest: request, displayName: nickname ?? '@${request.sender.username}', isSender: false,);
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
        return RequestListTile(transactionRequest: request, displayName: nickname ?? '@${request.receiver.username}', isSender: true,);
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

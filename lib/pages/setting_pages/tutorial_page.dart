import 'package:flutter/material.dart';
import 'package:money_minder/pages/tutorial_pages/account_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/ask_send_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/category_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/contacts_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/home_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/input_form_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/manage_request_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/online_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/split_bill_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/statistics_tutorial.dart';
import 'package:money_minder/pages/tutorial_pages/transactions_tutorial.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> with TickerProviderStateMixin{
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    HomeTutorial(),
    AccountTutorial(),
    CategoryTutorial(),
    InputFormTutorial(),
    TransactionTutorial(),
    StatisticsTutorial(),
    OnlineTutorial(),
    ContactsTutorial(),
    ManageRequestTutorial(),
    SendAskTutorial(),
    SplitBillTutorial()
  ];

  final List<String> _tabTitles = [
    'Home',
    'Accounts',
    'Categories',
    'Input Form',
    'Transactions',
    'Statistics',
    'Online',
    'Contacts',
    'Manage Requests',
    'Send/Ask Money',
    'Split Bill',
  ];

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: _pages.length , vsync: this,);
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tutorial'),centerTitle: true,),
      body: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentPageIndex == 0) {
                        return;
                      }
                      _updateCurrentPageIndex(_currentPageIndex - 1);
                    },
                    icon: Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                              children: _tabTitles.indexed.map((e) {
                                  final s  = e.$2;
                                  final index = e.$1;
                                  return SimpleDialogOption(
                                    onPressed: () {
                                      _updateCurrentPageIndex(index);
                                      Navigator.pop(context);
                                    },
                                    child: Text(s, style: TextStyle(fontSize: 18),),
                                  );
                              }).toList(),
                          );
                        }
                      );
                    },
                    height: 50,
                    color: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.borderRadius),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _tabTitles[_currentPageIndex],
                          style: TextStyle(
                            color: AppColor.darkText,
                            fontSize: AppSize.heading3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColor.darkIcon,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  /// go next
                  IconButton(
                    onPressed: () {
                      if (_currentPageIndex == _pages.length - 1) {
                        return;
                      }
                      _updateCurrentPageIndex(_currentPageIndex + 1);
                    },
                    icon: Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                    ),
                  ),
                ]
            ),
          ),
        ),
        body: PageView(
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          children: _pages
        ),
      ),
    );
  }
}

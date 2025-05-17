import 'package:flutter/material.dart';

import '../components/calendar_bar/calendar_bar.dart';

/// page that shows the transactions
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        tappable: true,
        selectedDate: "15052025",
        onDateTap: () {},
      ),
      body: const Center(
        child: Text('Transactions'),
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../../components/calendar_bar/calendar_bar.dart';

/// the page that shows the budget
class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        tappable: false,
        selectedDate: "15052025",
        onDateTap: () {},
      ),
      body: const Center(
        child: Text('Budget'),
      ),
    );
  }
}


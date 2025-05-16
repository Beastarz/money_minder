import 'package:flutter/material.dart';

import '../components/calendar_bar/calendar_bar.dart';

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


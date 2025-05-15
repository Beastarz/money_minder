import 'package:flutter/material.dart';

import '../components/calendar_bar/calendar_bar.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        tapable: true,
        selectedDate: "15052025",
        onDateTap: () {},
      ),
      body: const Center(
        child: Text('Statistics'),
      ),
    );
  }
}


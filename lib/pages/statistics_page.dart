import 'package:flutter/material.dart';

import '../components/calendar_bar/calendar_appbar.dart';

/// page that shows the statistics
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CalendarAppBar(
      //   tappable: true,
      //   selectedDate: "15052025",
      //   onDateTap: () {},
      // ),
      body: const Center(
        child: Text('Statistics'),
      ),
    );
  }
}


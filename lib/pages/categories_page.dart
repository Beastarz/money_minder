import 'package:flutter/material.dart';
import 'package:money_minder/components/categories_page/categories_page_content.dart';

import '../components/calendar_bar/calendar_bar.dart';

/// the page that shows the categories
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        tappable: true,
        selectedDate: "15052025",
        onDateTap: () {},
      ),
      body: CategoriesPageContent(),
    );
  }
}


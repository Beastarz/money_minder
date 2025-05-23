import 'package:flutter/material.dart';
import 'package:money_minder/models/date_filter.dart';
import 'package:money_minder/repositories/date_filter_repositories.dart';

class DateFilterProvider with ChangeNotifier {
  late DateFilter _dateFilter;
  late int _pageIndex;

  DateFilter get dateFilter => _dateFilter;
  int get initialPageIndex => _pageIndex;

  DateFilterRepositories dateFilterRepositories = DateFilterRepositories();

  Future<void> fetchDateFilter() async {
    _dateFilter = await dateFilterRepositories.getDateFilter();
    _pageIndex = _dateFilter.initialPageIndex;
    notifyListeners();
  }

  Future<void> updateDateFilter(DateFilter dateFilter) async {
    _dateFilter = dateFilter;
    await dateFilterRepositories.updateDateFilter(dateFilter);
    _pageIndex = dateFilter.initialPageIndex;
    notifyListeners();
  }

  Future<void> setPageIndex(int index) async {
    _pageIndex = index;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';

class SummaryTable extends StatelessWidget {
  const SummaryTable({
    super.key,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
  });

  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {

    final int days = endDate.difference(startDate).inDays + 1;
    int weeks = 0;
    int months = 0;
    int years = 0;
    if (days >= 7) {
      weeks = (days / 7).round();
    }
    if (days >= 28) {
      months = (days / 31).round();
    }
    if (days >= 360) {
      years = (days / 365).ceil();
    }

    return DataTable(
      horizontalMargin: 5,
      columnSpacing: 10,
      columns: const <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text(
              'Period',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Average',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
      rows: <DataRow>[
        DataRow(
          cells: <DataCell>[
            const DataCell(Text('Day')),
            DataCell(Text((totalAmount / days).toStringAsFixed(2))), // Formatted to 2 decimal places
          ],
        ),
        DataRow(
          cells: <DataCell>[
            const DataCell(Text('Week')),
            DataCell(Text(weeks != 0 ? (totalAmount / weeks).toStringAsFixed(2) : "N/A")), // Formatted to 2 decimal places
          ],
        ),
        DataRow(
          cells: <DataCell>[
            const DataCell(Text('Month')),
            DataCell(Text(months != 0 ? (totalAmount / months).toStringAsFixed(2) : "N/A")),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            const DataCell(Text('Year')),
            DataCell(Text(years != 0 ? (totalAmount / years).toStringAsFixed(2) : "N/A")),
          ],
        ),
      ],
    );
  }
}

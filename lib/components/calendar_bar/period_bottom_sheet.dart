import 'package:flutter/material.dart';

class PeriodBottomSheet extends StatelessWidget {
  const PeriodBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Period',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _periodTile(context, 'All time', Icons.all_inclusive),
              _periodTile(context, 'Week\n11 – 17 May', Icons.calendar_view_week),
              _periodTile(context, 'Today\n15 May', Icons.today),
              _periodTile(context, 'Select day', Icons.date_range),
              _periodTile(context, 'Month\nMay 2025', Icons.calendar_month),
              _periodTile(context, 'Year\n2025', Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodTile(BuildContext context, String label, IconData icon) {
    return MaterialButton(
      onPressed: () {},
      height: MediaQuery.of(context).size.width * 0.30,
      minWidth: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(12),
      color: Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

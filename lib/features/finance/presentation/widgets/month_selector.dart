import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (result != null) {
      onMonthChanged(DateTime(result.year, result.month, 1));
    }
  }

  DateTime _addMonths(DateTime d, int delta) {
    return DateTime(d.year, d.month + delta, 1);
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MM/yyyy').format(selectedMonth);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onMonthChanged(_addMonths(selectedMonth, -1)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _pick(context),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tháng $label',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onMonthChanged(_addMonths(selectedMonth, 1)),
          ),
        ],
      ),
    );
  }
}

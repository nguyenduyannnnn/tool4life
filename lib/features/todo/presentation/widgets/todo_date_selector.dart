import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';

class TodoDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const TodoDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  String _label(DateTime date) {
    final today = _stripTime(DateTime.now());
    final target = _stripTime(date);
    final diffDays = target.difference(today).inDays;
    final base = DateFormat('dd/MM/yyyy').format(date);
    if (diffDays == 0) return 'Hôm nay · $base';
    if (diffDays == -1) return 'Hôm qua · $base';
    if (diffDays == 1) return 'Ngày mai · $base';
    return base;
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _pick(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      onDateChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onDateChanged(
              selectedDate.subtract(const Duration(days: 1)),
            ),
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
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _label(selectedDate),
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
            onPressed: () => onDateChanged(
              selectedDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

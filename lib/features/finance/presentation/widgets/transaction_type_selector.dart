import 'package:flutter/material.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TransactionType.values.map((t) {
        final isSelected = t == selected;
        final color = t == TransactionType.income
            ? const Color(0xFF43A047)
            : const Color(0xFFE53935);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(t),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : AppColors.line,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                t.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.accent,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

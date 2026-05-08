import 'package:flutter/material.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionFilterChips extends StatelessWidget {
  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onChanged;

  const TransactionFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TransactionFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = TransactionFilter.values[index];
          final isSelected = f == selected;
          return ChoiceChip(
            label: Text(f.label),
            selected: isSelected,
            onSelected: (_) => onChanged(f),
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.line,
              ),
            ),
          );
        },
      ),
    );
  }
}

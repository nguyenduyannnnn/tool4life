import 'package:flutter/material.dart';

import 'package:changmeeting/common/design_system/ds.dart';
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
    final colors = context.dsColors;
    return Row(
      children: TransactionType.values.map((TransactionType t) {
        final bool isSelected = t == selected;
        final bool isIncome = t == TransactionType.income;
        final Color accent = isIncome ? colors.income : colors.expense;
        final Color bg = isIncome ? colors.incomeBg : colors.expenseBg;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? bg : colors.surface,
                borderRadius: DSRadius.brMd,
                border: Border.all(
                  color: isSelected ? accent : colors.outline,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                t.label,
                style: DSTypography.bodyBold.copyWith(
                  color: isSelected ? accent : colors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

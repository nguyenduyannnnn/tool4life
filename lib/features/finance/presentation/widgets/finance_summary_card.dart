import 'package:flutter/material.dart';

import 'package:changmeeting/common/design_system/ds.dart';
import 'package:changmeeting/common/utils/currency_formatter.dart';

class FinanceSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const FinanceSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      child: DSCard(
        variant: DSCardVariant.gradient,
        brandGlow: true,
        radius: DSRadius.xl,
        padding: const EdgeInsets.all(DSSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const DSText.label('Số dư tháng', color: Color(0xCCFFFFFF)),
            const SizedBox(height: DSSpacing.xs),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: balance),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return DSText.display(
                  CurrencyFormatter.format(value),
                  color: Colors.white,
                  maxLines: 1,
                );
              },
            ),
            const SizedBox(height: DSSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: _Stat(
                    label: 'Tổng thu',
                    amount: totalIncome,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Tổng chi',
                    amount: totalExpense,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _Stat({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: DSSpacing.xs),
              DSText.caption(label, color: Colors.white.withValues(alpha: 0.85)),
            ],
          ),
          const SizedBox(height: 2),
          DSText.bodyBold(
            CurrencyFormatter.format(amount),
            color: Colors.white,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

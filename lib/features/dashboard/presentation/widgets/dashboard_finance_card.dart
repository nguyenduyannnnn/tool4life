import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/design_system/ds.dart';
import 'package:changmeeting/common/utils/currency_formatter.dart';
import 'package:changmeeting/features/finance/domain/entities/finance_category_entity.dart';
import 'package:changmeeting/features/finance/domain/entities/transaction_entity.dart';
import 'package:changmeeting/features/finance/presentation/widgets/category_icon_map.dart';

class DashboardFinanceCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<TransactionEntity> recentTransactions;
  final List<FinanceCategoryEntity> categories;
  final VoidCallback onQuickAdd;
  final VoidCallback onOpenFinanceTab;

  const DashboardFinanceCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.recentTransactions = const <TransactionEntity>[],
    this.categories = const <FinanceCategoryEntity>[],
    required this.onQuickAdd,
    required this.onOpenFinanceTab,
  });

  bool get _isEmpty => totalIncome == 0 && totalExpense == 0;

  FinanceCategoryEntity? _findCategory(String id) {
    for (final FinanceCategoryEntity c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.sm,
      ),
      child: DSCard(
        variant: DSCardVariant.elevated,
        radius: DSRadius.xl,
        onTap: onOpenFinanceTab,
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                DSAvatar(
                  size: DSAvatarSize.md,
                  icon: Icons.account_balance_wallet_outlined,
                  bgColor: DSPalette.catEmeraldBg,
                  fgColor: DSPalette.catEmerald,
                ),
                const SizedBox(width: DSSpacing.md),
                const Expanded(
                  child: DSText.h3('Tài chính tháng này'),
                ),
                DSIconButton(
                  icon: Icons.add,
                  variant: DSIconButtonVariant.gradient,
                  size: DSIconButtonSize.sm,
                  onTap: onQuickAdd,
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.lg),
            if (_isEmpty)
              _emptyState(context)
            else ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCell(
                      label: 'Đã tiêu',
                      amount: totalExpense,
                      color: colors.expense,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  Container(width: 1, height: 36, color: colors.divider),
                  Expanded(
                    child: _StatCell(
                      label: 'Tổng thu',
                      amount: totalIncome,
                      color: colors.income,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),
              if (recentTransactions.isNotEmpty) ...<Widget>[
                const SizedBox(height: DSSpacing.lg),
                Container(height: 1, color: colors.divider),
                const SizedBox(height: DSSpacing.md),
                DSText.label('Giao dịch gần đây',
                    color: colors.textTertiary),
                const SizedBox(height: DSSpacing.sm),
                ...recentTransactions.map(_recentRow),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _recentRow(TransactionEntity tx) {
    final bool isIncome = tx.type == TransactionType.income;
    final cat = _findCategory(tx.categoryId);
    final IconData iconData = iconForName(cat?.icon ?? '');
    return Builder(builder: (context) {
      final colors = context.dsColors;
      final Color color = isIncome ? colors.income : colors.expense;
      final Color bg = isIncome ? colors.incomeBg : colors.expenseBg;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: Row(
          children: <Widget>[
            DSAvatar(
              size: DSAvatarSize.sm,
              icon: iconData,
              bgColor: bg,
              fgColor: color,
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DSText.bodyBold(tx.title, maxLines: 1),
                  DSText.caption(DateFormat('dd/MM').format(tx.date)),
                ],
              ),
            ),
            DSText.bodyBold(
              CurrencyFormatter.formatSigned(tx.amount, isIncome: isIncome),
              color: color,
            ),
          ],
        ),
      );
    });
  }

  Widget _emptyState(BuildContext context) {
    final colors = context.dsColors;
    return Row(
      children: <Widget>[
        DSAvatar(
          size: DSAvatarSize.md,
          icon: Icons.savings_outlined,
          bgColor: colors.accentMuted,
          fgColor: colors.accentStrong,
        ),
        const SizedBox(width: DSSpacing.md),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DSText.bodyBold('Chưa có giao dịch'),
              SizedBox(height: 2),
              DSText.caption('Thêm giao dịch đầu tiên'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _StatCell({
    required this.label,
    required this.amount,
    required this.color,
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
              Icon(icon, size: 14, color: color),
              const SizedBox(width: DSSpacing.xs),
              DSText.caption(label),
            ],
          ),
          const SizedBox(height: 2),
          DSText.bodyBold(
            CurrencyFormatter.format(amount),
            color: color,
          ),
        ],
      ),
    );
  }
}

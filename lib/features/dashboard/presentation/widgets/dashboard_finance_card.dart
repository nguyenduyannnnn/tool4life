import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';
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
    this.recentTransactions = const [],
    this.categories = const [],
    required this.onQuickAdd,
    required this.onOpenFinanceTab,
  });

  bool get _isEmpty => totalIncome == 0 && totalExpense == 0;

  FinanceCategoryEntity? _findCategory(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenFinanceTab,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tài chính tháng này',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onQuickAdd,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isEmpty)
                  _emptyState(context)
                else ...[
                  _balanceRow(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _cell(
                          label: 'Đã tiêu',
                          value: totalExpense,
                          color: const Color(0xFFE53935),
                          icon: Icons.arrow_upward,
                        ),
                      ),
                      Container(
                          width: 1, height: 32, color: AppColors.line),
                      Expanded(
                        child: _cell(
                          label: 'Tổng thu',
                          value: totalIncome,
                          color: const Color(0xFF43A047),
                          icon: Icons.arrow_downward,
                        ),
                      ),
                    ],
                  ),
                  if (recentTransactions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(height: 1, color: AppColors.line),
                    const SizedBox(height: 10),
                    Text(
                      'Giao dịch gần đây',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...recentTransactions.map(_recentRow),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _balanceRow() {
    final color =
        balance < 0 ? const Color(0xFFE53935) : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Còn lại',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          Text(
            CurrencyFormatter.format(balance),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.format(value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentRow(TransactionEntity tx) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF43A047) : const Color(0xFFE53935);
    final cat = _findCategory(tx.categoryId);
    final iconData = iconForName(cat?.icon ?? '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  DateFormat('dd/MM').format(tx.date),
                  style: TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.formatSigned(tx.amount, isIncome: isIncome),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Còn lại: 0 đ · Đã tiêu: 0 đ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Thêm giao dịch đầu tiên',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

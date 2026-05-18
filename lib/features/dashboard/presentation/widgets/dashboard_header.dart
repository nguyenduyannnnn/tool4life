import 'package:flutter/material.dart';

import 'package:changmeeting/common/design_system/ds.dart';
import 'package:changmeeting/common/utils/currency_formatter.dart';

class DashboardHeader extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final String userName;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.userName = 'Dian',
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      margin: EdgeInsets.fromLTRB(
        DSSpacing.lg,
        topInset + DSSpacing.md,
        DSSpacing.lg,
        DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              DSAvatar(
                size: DSAvatarSize.lg,
                bgColor: tokens.colors.accentMuted,
                fgColor: tokens.colors.accentStrong,
                child: ClipOval(
                  child: Image.asset(
                    'assets/image/tool4life_logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person_outline,
                      size: 24,
                      color: tokens.colors.accentStrong,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DSText.caption('Hello',
                        color: tokens.colors.textTertiary),
                    DSText.h2(userName, maxLines: 1),
                  ],
                ),
              ),
              DSIconButton(
                icon: Icons.notifications_outlined,
                variant: DSIconButtonVariant.soft,
                size: DSIconButtonSize.md,
                onTap: onNotificationTap ?? () {},
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.lg),
          _HeroBalanceCard(
            balance: balance,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
          ),
        ],
      ),
    );
  }
}

class _HeroBalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const _HeroBalanceCard({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return DSCard(
      variant: DSCardVariant.gradient,
      brandGlow: true,
      radius: DSRadius.xl,
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DSText.label(
            'Số dư tháng này',
            color: Color(0xCCFFFFFF),
          ),
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
                child: _MiniStat(
                  label: 'Thu',
                  amount: totalIncome,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Chi',
                  amount: totalExpense,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _MiniStat({
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

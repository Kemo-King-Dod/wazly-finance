import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated balance display widget with smooth transitions
class AnimatedBalanceDisplay extends StatelessWidget {
  final double balance;
  final String currency;

  const AnimatedBalanceDisplay({
    super.key,
    required this.balance,
    this.currency = 'LYD',
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: currency == 'LYD' ? 'د.ل' : '\$',
      decimalDigits: 2,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: Text(
        formatter.format(balance),
        key: ValueKey<double>(balance),
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: balance >= 0 ? AppTheme.incomeColor : AppTheme.debtColor,
          letterSpacing: -1.5,
        ),
      ),
    );
  }
}

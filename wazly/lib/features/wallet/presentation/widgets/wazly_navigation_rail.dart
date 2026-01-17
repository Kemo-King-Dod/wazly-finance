import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WazlyNavigationRail extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const WazlyNavigationRail({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(
            color: AppTheme.incomeColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildRailItem(
            icon: Icons.dashboard_rounded,
            route: '/',
            isSelected: currentRoute == '/',
          ),
          _buildRailItem(
            icon: Icons.history_rounded,
            route: '/history',
            isSelected: currentRoute == '/history',
          ),
          _buildRailItem(
            icon: Icons.people_alt_rounded,
            route: '/accounts',
            isSelected: currentRoute == '/accounts',
          ),
          _buildRailItem(
            icon: Icons.pie_chart_rounded,
            route: '/analytics',
            isSelected: currentRoute == '/analytics',
          ),
          const Spacer(),
          _buildRailItem(
            icon: Icons.settings_rounded,
            route: '/settings',
            isSelected: currentRoute == '/settings',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRailItem({
    required IconData icon,
    required String route,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tooltip(
        message: route == '/'
            ? 'Dashboard'
            : route.replaceAll('/', '').toUpperCase(),
        child: InkWell(
          onTap: () => onNavigate(route),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.incomeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppTheme.incomeColor : AppTheme.textSecondary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

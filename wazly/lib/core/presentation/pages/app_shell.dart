import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:wazly/core/presentation/pages/minimal_dashboard_screen.dart';
import 'package:wazly/core/presentation/pages/minimal_people_screen.dart';
import 'package:wazly/core/presentation/pages/minimal_analytics_screen.dart';
import 'package:wazly/core/presentation/pages/minimal_activity_screen.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MinimalDashboardScreen(),
    MinimalPeopleScreen(),
    MinimalAnalyticsScreen(),
    MinimalActivityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;

    final tabs = [
      _NavTab(FluentIcons.home_24_regular, FluentIcons.home_24_filled, l.homeNav),
      _NavTab(FluentIcons.people_24_regular, FluentIcons.people_24_filled, l.peopleTitle),
      _NavTab(FluentIcons.data_bar_vertical_24_regular, FluentIcons.data_bar_vertical_24_filled, l.analytics),
      _NavTab(FluentIcons.receipt_24_regular, FluentIcons.receipt_24_filled, l.activityTitle),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isActive = _currentIndex == i;
                final tab = tabs[i];

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_currentIndex != i) {
                        HapticFeedback.selectionClick();
                        setState(() => _currentIndex = i);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.symmetric(
                              horizontal: isActive ? 20 : 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isActive ? tab.activeIcon : tab.icon,
                              size: 24,
                              color: isActive
                                  ? primary
                                  : AppTheme.textSecondary.withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isActive ? 11.5 : 11,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive
                                  ? primary
                                  : AppTheme.textSecondary.withValues(alpha: 0.55),
                              fontFamily: 'Almarai',
                            ),
                            child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavTab(this.icon, this.activeIcon, this.label);
}

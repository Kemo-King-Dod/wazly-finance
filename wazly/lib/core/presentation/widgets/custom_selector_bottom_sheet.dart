import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:wazly/core/theme/app_theme.dart';

enum SelectorType { language, country }

class SelectorItem {
  final String label;
  final String value;
  final String? leadingIcon; // emoji
  final String? badgeText; // e.g. LYD, USD

  const SelectorItem({
    required this.label,
    required this.value,
    this.leadingIcon,
    this.badgeText,
  });
}

class CustomSelectorBottomSheet extends StatelessWidget {
  final String title;
  final SelectorType type;
  final List<SelectorItem> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const CustomSelectorBottomSheet({
    super.key,
    required this.title,
    required this.type,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required SelectorType type,
    required List<SelectorItem> items,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: CustomSelectorBottomSheet(
          title: title,
          type: type,
          items: items,
          selectedValue: selectedValue,
          onSelected: onSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),

        // List
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedValue == item.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    onSelected(item.value);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                          : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        if (item.leadingIcon != null) ...[
                          Text(
                            item.leadingIcon!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 16),
                        ],
                        
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),

                        if (item.badgeText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.lightSurfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.badgeText!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        if (isSelected)
                          Icon(
                            FluentIcons.checkmark_circle_24_filled,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          )
                        else
                          Icon(
                            FluentIcons.circle_24_regular,
                            color: AppTheme.textSecondary.withValues(alpha: 0.3),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

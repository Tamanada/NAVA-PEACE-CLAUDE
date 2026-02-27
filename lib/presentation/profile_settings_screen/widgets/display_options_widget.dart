import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Display options widget for managing display preferences
class DisplayOptionsWidget extends StatelessWidget {
  final bool balanceVisibility;
  final bool reducedMotion;
  final String timezoneFormat;
  final ValueChanged<bool> onBalanceVisibilityChanged;
  final ValueChanged<bool> onReducedMotionChanged;
  final ValueChanged<String> onTimezoneFormatChanged;

  const DisplayOptionsWidget({
    super.key,
    required this.balanceVisibility,
    required this.reducedMotion,
    required this.timezoneFormat,
    required this.onBalanceVisibilityChanged,
    required this.onReducedMotionChanged,
    required this.onTimezoneFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Display Options',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildToggleItem(
            theme: theme,
            icon: 'visibility',
            title: 'Balance Visibility',
            subtitle: 'Show token balance on dashboard',
            value: balanceVisibility,
            onChanged: onBalanceVisibilityChanged,
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildToggleItem(
            theme: theme,
            icon: 'accessibility_new',
            title: 'Reduced Motion',
            subtitle: 'Minimize animations and transitions',
            value: reducedMotion,
            onChanged: onReducedMotionChanged,
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildDropdownItem(
            theme: theme,
            icon: 'schedule',
            title: 'Timezone Display',
            subtitle: 'Choose your preferred time format',
            value: timezoneFormat,
            items: ['UTC+7 only', 'UTC+7 with local', 'Local only'],
            onChanged: onTimezoneFormatChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDropdownItem({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

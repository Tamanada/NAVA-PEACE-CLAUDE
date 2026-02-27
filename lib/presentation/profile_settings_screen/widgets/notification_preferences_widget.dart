import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Notification preferences widget for managing notification settings
class NotificationPreferencesWidget extends StatelessWidget {
  final bool dailyClaimReminders;
  final bool streakMilestoneAlerts;
  final bool referralNotifications;
  final ValueChanged<bool> onDailyClaimChanged;
  final ValueChanged<bool> onStreakMilestoneChanged;
  final ValueChanged<bool> onReferralChanged;

  const NotificationPreferencesWidget({
    super.key,
    required this.dailyClaimReminders,
    required this.streakMilestoneAlerts,
    required this.referralNotifications,
    required this.onDailyClaimChanged,
    required this.onStreakMilestoneChanged,
    required this.onReferralChanged,
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
            'Notification Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildNotificationItem(
            theme: theme,
            icon: 'notifications_active',
            title: 'Daily Claim Reminders',
            subtitle: 'Get notified when your daily claim is available',
            value: dailyClaimReminders,
            onChanged: onDailyClaimChanged,
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildNotificationItem(
            theme: theme,
            icon: 'local_fire_department',
            title: 'Streak Milestone Alerts',
            subtitle: 'Celebrate your streak achievements',
            value: streakMilestoneAlerts,
            onChanged: onStreakMilestoneChanged,
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildNotificationItem(
            theme: theme,
            icon: 'group_add',
            title: 'Referral Notifications',
            subtitle: 'Updates on your referral rewards',
            value: referralNotifications,
            onChanged: onReferralChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
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
}

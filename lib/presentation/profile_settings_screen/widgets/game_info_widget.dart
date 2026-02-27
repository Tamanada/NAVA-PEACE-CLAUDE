import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Game information widget displaying game mechanics and status
class GameInfoWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const GameInfoWidget({super.key, required this.userData});

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
            'Game Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildInfoItem(
            theme: theme,
            icon: 'trending_down',
            label: 'Current Period',
            value: 'Period ${userData["currentPeriod"]} of 6',
            description: 'Halving system reduces rewards every 30 days',
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildInfoItem(
            theme: theme,
            icon: 'event',
            label: 'Next Reward Reduction',
            value: userData["nextReductionDate"] as String,
            description: 'Rewards will be halved on this date',
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildCalculationMethodology(theme),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required ThemeData theme,
    required String icon,
    required String label,
    required String value,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
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
    );
  }

  Widget _buildCalculationMethodology(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'calculate',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Text(
              'Calculation Methodology',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMethodologyItem(
                theme: theme,
                title: 'Daily Base Reward',
                description: 'Starts at 100 NAVA, halves every 30 days',
              ),
              SizedBox(height: 1.h),
              _buildMethodologyItem(
                theme: theme,
                title: 'Streak Bonuses',
                description: '7, 14, 21, 30 days: +50, +100, +200, +500 NAVA',
              ),
              SizedBox(height: 1.h),
              _buildMethodologyItem(
                theme: theme,
                title: 'Badge Multipliers',
                description: 'Bronze to Diamond: 1.0x to 2.5x multiplier',
              ),
              SizedBox(height: 1.h),
              _buildMethodologyItem(
                theme: theme,
                title: 'Referral Rewards',
                description: '10% of referee earnings for 180 days',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodologyItem({
    required ThemeData theme,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displayed when user has no referrals yet
class EmptyReferralsWidget extends StatelessWidget {
  final VoidCallback onSharePressed;

  const EmptyReferralsWidget({super.key, required this.onSharePressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImageWidget(
            imageUrl:
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=400&fit=crop',
            width: 50.w,
            height: 50.w,
            fit: BoxFit.contain,
            semanticLabel:
                'Illustration of diverse group of people connected by network lines representing referral network',
          ),
          SizedBox(height: 3.h),
          Text(
            'Start Building Your Network',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Share your referral code with friends and earn bonus tokens when they join and claim daily rewards!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSharePressed,
              icon: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Share Your Code'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: theme.colorScheme.tertiary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Earn up to 7x multiplier on rewards by building your referral network!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

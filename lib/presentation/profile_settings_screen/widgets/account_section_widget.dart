import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Account section widget displaying user account information
class AccountSectionWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AccountSectionWidget({super.key, required this.userData});

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
            'Account',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildAccountItem(
            theme: theme,
            icon: 'smartphone',
            label: 'Device ID',
            value: userData["deviceId"] as String,
            isReadOnly: true,
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildAccountItem(
            theme: theme,
            icon: 'event',
            label: 'Registration Date',
            value: userData["registrationDate"] as String,
            isReadOnly: true,
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildAccountItem(
            theme: theme,
            icon: 'share',
            label: 'Referral Code',
            value: userData["referralCode"] as String,
            isReadOnly: false,
            onCopy: () =>
                _copyToClipboard(context, userData["referralCode"] as String),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem({
    required ThemeData theme,
    required String icon,
    required String label,
    required String value,
    required bool isReadOnly,
    VoidCallback? onCopy,
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
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        onCopy != null
            ? IconButton(
                icon: CustomIconWidget(
                  iconName: 'content_copy',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                onPressed: onCopy,
                tooltip: 'Copy',
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

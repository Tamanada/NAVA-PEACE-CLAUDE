import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for referral code input with validation
class ReferralCodeFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final bool showValidation;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;

  const ReferralCodeFieldWidget({
    super.key,
    required this.controller,
    required this.isValid,
    required this.showValidation,
    required this.onChanged,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Referral Code',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              '(Optional)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: showValidation
                  ? (isValid
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.error)
                  : theme.colorScheme.outline,
              width: showValidation ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter referral code',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 12,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                ),
              ),
              if (showValidation)
                Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: CustomIconWidget(
                    iconName: isValid ? 'check_circle' : 'cancel',
                    size: 6.w,
                    color: isValid
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.error,
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPaste,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(1.5.w),
                    margin: EdgeInsets.only(right: 2.w),
                    child: CustomIconWidget(
                      iconName: 'content_paste',
                      size: 5.w,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          showValidation
              ? (isValid
                    ? 'Valid referral code! You\'ll get bonus rewards'
                    : 'Invalid referral code. Please check and try again')
              : 'Have a referral code? Enter it to get bonus rewards',
          style: theme.textTheme.bodySmall?.copyWith(
            color: showValidation
                ? (isValid
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.error)
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

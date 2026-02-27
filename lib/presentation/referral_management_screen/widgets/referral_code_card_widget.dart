import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying user's referral code with copy and share functionality
class ReferralCodeCardWidget extends StatefulWidget {
  final String referralCode;
  final VoidCallback onShare;

  const ReferralCodeCardWidget({
    super.key,
    required this.referralCode,
    required this.onShare,
  });

  @override
  State<ReferralCodeCardWidget> createState() => _ReferralCodeCardWidgetState();
}

class _ReferralCodeCardWidgetState extends State<ReferralCodeCardWidget> {
  bool _showCopiedFeedback = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.referralCode));
    setState(() => _showCopiedFeedback = true);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _showCopiedFeedback = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Referral Code',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.referralCode,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showCopiedFeedback
                      ? Row(
                          key: const ValueKey('copied'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Copied!',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : IconButton(
                          key: const ValueKey('copy'),
                          onPressed: _copyToClipboard,
                          icon: CustomIconWidget(
                            iconName: 'content_copy',
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                          tooltip: 'Copy code',
                        ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: widget.onShare,
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Share Options'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

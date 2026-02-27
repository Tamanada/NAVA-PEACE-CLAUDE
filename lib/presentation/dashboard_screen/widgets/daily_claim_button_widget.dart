import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Daily claim button with countdown timer and disabled state management
class DailyClaimButtonWidget extends StatefulWidget {
  final bool hasClaimedToday;
  final int todayTokens;
  final DateTime? nextClaimTime;
  final VoidCallback onClaim;

  const DailyClaimButtonWidget({
    super.key,
    required this.hasClaimedToday,
    required this.todayTokens,
    this.nextClaimTime,
    required this.onClaim,
  });

  @override
  State<DailyClaimButtonWidget> createState() => _DailyClaimButtonWidgetState();
}

class _DailyClaimButtonWidgetState extends State<DailyClaimButtonWidget> {
  Timer? _countdownTimer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    if (widget.hasClaimedToday && widget.nextClaimTime != null) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(DailyClaimButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasClaimedToday != oldWidget.hasClaimedToday) {
      if (widget.hasClaimedToday && widget.nextClaimTime != null) {
        _startCountdown();
      } else {
        _countdownTimer?.cancel();
      }
    }
  }

  void _startCountdown() {
    _updateTimeRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    if (widget.nextClaimTime == null) return;

    final now = DateTime.now();
    final difference = widget.nextClaimTime!.difference(now);

    if (difference.isNegative) {
      setState(() {
        _timeRemaining = 'Available now!';
      });
      _countdownTimer?.cancel();
      return;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    setState(() {
      _timeRemaining =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 16.h),
      child: widget.hasClaimedToday
          ? _buildClaimedState(theme)
          : _buildClaimableState(theme),
    );
  }

  Widget _buildClaimableState(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onClaim,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.secondary,
                theme.colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'toll',
                    color: theme.colorScheme.onSecondary,
                    size: 32,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '+${widget.todayTokens}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                'Claim Your Daily Tokens',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Tap to claim and maintain your streak',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimedState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: theme.colorScheme.tertiary,
            size: 48,
          ),
          SizedBox(height: 1.h),
          Text(
            'Claimed Today!',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Come back tomorrow',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_timeRemaining.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _timeRemaining,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

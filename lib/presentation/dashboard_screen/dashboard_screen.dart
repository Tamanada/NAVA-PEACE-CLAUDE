import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/badge_level_widget.dart';
import './widgets/daily_claim_button_widget.dart';
import './widgets/hero_balance_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/streak_counter_widget.dart';

/// Dashboard Screen - Primary hub for daily token claiming and progress tracking
/// Implements gamified earning system with real-time updates and streak mechanics
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRefreshing = false;
  bool _hasClaimedToday = false;
  int _currentStreak = 5;
  int _currentBalance = 1250;
  int _todayTokens = 50;
  DateTime? _nextClaimTime;
  String _badgeLevel = "Bronze";
  double _badgeProgress = 0.6;
  int _totalEarned = 3450;
  int _referralCount = 12;
  int _daysRemaining = 175;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    // Simulate loading dashboard data
    await Future.delayed(const Duration(milliseconds: 500));

    // Set next claim time if already claimed today
    if (_hasClaimedToday) {
      final now = DateTime.now();
      _nextClaimTime = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate API call for real-time data update
    await Future.delayed(const Duration(seconds: 1));

    // Update with fresh data
    setState(() {
      _isRefreshing = false;
      // Simulate data refresh
      _currentBalance += 0; // Would update from server
    });
  }

  Future<void> _handleDailyClaim() async {
    if (_hasClaimedToday) return;

    // Show loading state
    setState(() => _isRefreshing = true);

    // Simulate claim API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Update state after successful claim
    setState(() {
      _hasClaimedToday = true;
      _currentBalance += _todayTokens;
      _totalEarned += _todayTokens;
      _currentStreak += 1;
      _isRefreshing = false;

      // Set next claim time
      final now = DateTime.now();
      _nextClaimTime = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    });

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully claimed $_todayTokens tokens!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleShareReferral() {
    // Navigate to referral management or show share dialog
    Navigator.pushNamed(context, '/referral-management-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: DashboardAppBar(
        title: 'NAVA PEACE',
        actions: [
          AppBarAction(
            icon: Icons.notifications_outlined,
            onPressed: () {
              // Handle notifications
            },
            tooltip: 'Notifications',
            showBadge: true,
            badgeCount: 3,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: SafeArea(
          child: _isRefreshing
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Balance Section
                        HeroBalanceWidget(currentBalance: _currentBalance),
                        SizedBox(height: 3.h),

                        // Daily Claim Button
                        DailyClaimButtonWidget(
                          hasClaimedToday: _hasClaimedToday,
                          todayTokens: _todayTokens,
                          nextClaimTime: _nextClaimTime,
                          onClaim: _handleDailyClaim,
                        ),
                        SizedBox(height: 3.h),

                        // Streak Counter Card
                        StreakCounterWidget(currentStreak: _currentStreak),
                        SizedBox(height: 3.h),

                        // Badge Level Indicator
                        BadgeLevelWidget(
                          badgeLevel: _badgeLevel,
                          progress: _badgeProgress,
                        ),
                        SizedBox(height: 3.h),

                        // Quick Stats Section
                        QuickStatsWidget(
                          totalEarned: _totalEarned,
                          referralCount: _referralCount,
                          daysRemaining: _daysRemaining,
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: BottomNavItem.homeHome,
        onItemSelected: (item) {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleShareReferral,
        icon: CustomIconWidget(
          iconName: 'share',
          color: theme.colorScheme.onSecondary,
          size: 20,
        ),
        label: Text(
          'Share & Earn',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        backgroundColor: theme.colorScheme.secondary,
        elevation: 6.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

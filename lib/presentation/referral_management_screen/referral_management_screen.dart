import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/referral_share_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/badge_progression_widget.dart';
import './widgets/empty_referrals_widget.dart';
import './widgets/referral_code_card_widget.dart';
import './widgets/referral_list_item_widget.dart';
import './widgets/referral_statistics_widget.dart';
import './widgets/ranking_card_widget.dart';

/// Referral Management Screen for NAVA PEACE token reward system
/// Enables users to share referral codes and track referral-based earnings
class ReferralManagementScreen extends StatefulWidget {
  const ReferralManagementScreen({super.key});

  @override
  State<ReferralManagementScreen> createState() =>
      _ReferralManagementScreenState();
}

class _ReferralManagementScreenState extends State<ReferralManagementScreen> {
  bool _isLoading = false;
  bool _isSyncing = false;

  // Services
  final ReferralShareService _shareService = ReferralShareService();

  // Global key for ranking card capture
  final GlobalKey _rankingCardKey = GlobalKey();

  // Mock user referral data
  final String _userReferralCode = 'NAVA2026XYZ';
  final String _userName = 'Peace Advocate';
  final int _globalRank = 127;
  final int _totalReferrals = 12;
  final int _activeReferrals = 8;
  final double _totalEarnings = 2450.75;
  final String _currentBadge = 'Silver';
  final double _currentMultiplier = 2.0;
  final double _nextMultiplier = 3.0;
  final int _currentReferralCount = 12;
  final int _nextBadgeRequirement = 20;

  // Mock referral list data
  final List<Map<String, dynamic>> _referralsList = [
    {
      'userId': 'User #8472',
      'joinDate': '2025-12-28',
      'currentStreak': 15,
      'earningsContributed': 325.50,
      'isActive': true,
    },
    {
      'userId': 'User #7391',
      'joinDate': '2025-12-25',
      'currentStreak': 18,
      'earningsContributed': 412.25,
      'isActive': true,
    },
    {
      'userId': 'User #6284',
      'joinDate': '2025-12-20',
      'currentStreak': 23,
      'earningsContributed': 587.80,
      'isActive': true,
    },
    {
      'userId': 'User #5173',
      'joinDate': '2025-12-15',
      'currentStreak': 28,
      'earningsContributed': 698.40,
      'isActive': true,
    },
    {
      'userId': 'User #4062',
      'joinDate': '2025-12-10',
      'currentStreak': 5,
      'earningsContributed': 142.30,
      'isActive': true,
    },
    {
      'userId': 'User #3951',
      'joinDate': '2025-12-05',
      'currentStreak': 0,
      'earningsContributed': 89.50,
      'isActive': false,
    },
    {
      'userId': 'User #2840',
      'joinDate': '2025-11-28',
      'currentStreak': 12,
      'earningsContributed': 195.00,
      'isActive': true,
    },
    {
      'userId': 'User #1729',
      'joinDate': '2025-11-20',
      'currentStreak': 0,
      'earningsContributed': 0.00,
      'isActive': false,
    },
    {
      'userId': 'User #9618',
      'joinDate': '2025-11-15',
      'currentStreak': 8,
      'earningsContributed': 0.00,
      'isActive': true,
    },
    {
      'userId': 'User #8507',
      'joinDate': '2025-11-10',
      'currentStreak': 0,
      'earningsContributed': 0.00,
      'isActive': false,
    },
    {
      'userId': 'User #7396',
      'joinDate': '2025-11-05',
      'currentStreak': 0,
      'earningsContributed': 0.00,
      'isActive': false,
    },
    {
      'userId': 'User #6285',
      'joinDate': '2025-10-28',
      'currentStreak': 0,
      'earningsContributed': 0.00,
      'isActive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshReferralData() async {
    setState(() => _isSyncing = true);

    // Simulate server synchronization
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSyncing = false);
      _showSuccessNotification('Referral data synced successfully');
    }
  }

  void _shareReferralCode() {
    _shareService.showShareOptions(
      context: context,
      referralCode: _userReferralCode,
      rankingCardKey: _rankingCardKey,
      userName: _userName,
      userRank: _globalRank,
      userBadge: _currentBadge,
    );
  }

  void _viewReferralDetails(Map<String, dynamic> referral) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReferralDetailsSheet(referral),
    );
  }

  Widget _buildReferralDetailsSheet(Map<String, dynamic> referral) {
    final theme = Theme.of(context);

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        color: (referral['isActive'] as bool)
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.1,
                              ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'person',
                          color: (referral['isActive'] as bool)
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            referral['userId'] as String,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Joined: ${referral['joinDate']}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                _buildDetailRow(
                  context: context,
                  icon: 'local_fire_department',
                  label: 'Current Streak',
                  value: '${referral['currentStreak']} days',
                  color: (referral['currentStreak'] as int) >= 7
                      ? Colors.orange
                      : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: 2.h),
                _buildDetailRow(
                  context: context,
                  icon: 'account_balance_wallet',
                  label: 'Earnings Contributed',
                  value:
                      '\$${(referral['earningsContributed'] as double).toStringAsFixed(2)}',
                  color: theme.colorScheme.secondary,
                ),
                SizedBox(height: 2.h),
                _buildDetailRow(
                  context: context,
                  icon: 'check_circle',
                  label: 'Status',
                  value: (referral['isActive'] as bool) ? 'Active' : 'Inactive',
                  color: (referral['isActive'] as bool)
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.error,
                ),
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'You earn bonus tokens when this user maintains their daily claim streak!',
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(iconName: icon, color: color, size: 20),
          ),
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
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSuccessNotification(String message) {
    Flushbar(
      message: message,
      icon: CustomIconWidget(
        iconName: 'check_circle',
        color: Colors.white,
        size: 24,
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      margin: EdgeInsets.all(2.w),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: DashboardAppBar(
        title: 'Referrals',
        actions: [
          if (_isSyncing)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshReferralData,
              color: theme.colorScheme.primary,
              child: _totalReferrals == 0
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 80.h,
                        child: Column(
                          children: [
                            ReferralCodeCardWidget(
                              referralCode: _userReferralCode,
                              onShare: _shareReferralCode,
                            ),
                            Expanded(
                              child: EmptyReferralsWidget(
                                onSharePressed: _shareReferralCode,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        ReferralCodeCardWidget(
                          referralCode: _userReferralCode,
                          onShare: _shareReferralCode,
                        ),

                        // Add invisible ranking card for capture
                        Opacity(
                          opacity: 0.0,
                          child: RepaintBoundary(
                            key: _rankingCardKey,
                            child: RankingCardWidget(
                              userName: _userName,
                              globalRank: _globalRank,
                              badgeLevel: _currentBadge,
                              totalReferrals: _totalReferrals,
                              activeReferrals: _activeReferrals,
                              totalEarnings: _totalEarnings,
                              referralCode: _userReferralCode,
                            ),
                          ),
                        ),

                        ReferralStatisticsWidget(
                          totalReferrals: _totalReferrals,
                          activeReferrals: _activeReferrals,
                          totalEarnings: _totalEarnings,
                          currentBadge: _currentBadge,
                          badgeMultiplier: _currentMultiplier,
                        ),
                        BadgeProgressionWidget(
                          currentBadge: _currentBadge,
                          currentReferrals: _currentReferralCount,
                          nextBadgeRequirement: _nextBadgeRequirement,
                          currentMultiplier: _currentMultiplier,
                          nextMultiplier: _nextMultiplier,
                        ),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'Your Referrals',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        ...(_referralsList.map((referral) {
                          return ReferralListItemWidget(
                            userId: referral['userId'] as String,
                            joinDate: referral['joinDate'] as String,
                            currentStreak: referral['currentStreak'] as int,
                            earningsContributed:
                                referral['earningsContributed'] as double,
                            isActive: referral['isActive'] as bool,
                            onViewDetails: () => _viewReferralDetails(referral),
                          );
                        }).toList()),
                        SizedBox(height: 10.h),
                      ],
                    ),
            ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: BottomNavItem.market,
        onItemSelected: (item) {},
      ),
    );
  }
}

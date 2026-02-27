import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/account_section_widget.dart';
import './widgets/display_options_widget.dart';
import './widgets/game_info_widget.dart';
import './widgets/header_summary_widget.dart';
import './widgets/notification_preferences_widget.dart';
import './widgets/security_section_widget.dart';
import './widgets/support_section_widget.dart';

/// Profile Settings Screen for token earning game
/// Provides comprehensive account management and app configuration
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Mock user data
  final Map<String, dynamic> _userData = {
    "deviceId": "DEVICE-8F3A-9B2C-1D4E",
    "registrationDate": "2025-12-15",
    "referralCode": "NAVA2025XYZ",
    "totalTokens": 12450.75,
    "badgeLevel": 3,
    "badgeName": "Silver Champion",
    "currentStreak": 28,
    "longestStreak": 45,
    "daysRemaining": 152,
    "currentPeriod": 2,
    "nextReductionDate": "2026-02-01",
    "appVersion": "1.2.0",
  };

  // Notification preferences
  bool _dailyClaimReminders = true;
  bool _streakMilestoneAlerts = true;
  bool _referralNotifications = false;

  // Display options
  bool _balanceVisibility = true;
  bool _reducedMotion = false;
  String _timezoneFormat = "UTC+7 with local";

  // Security settings
  bool _biometricAuth = false;
  String _autoLogoutTiming = "30 minutes";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Profile Settings',
        variant: AppBarVariant.standard,
        showElevation: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'logout',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary Section
              HeaderSummaryWidget(userData: _userData),

              SizedBox(height: 2.h),

              // Account Section
              AccountSectionWidget(userData: _userData),

              SizedBox(height: 2.h),

              // Notification Preferences
              NotificationPreferencesWidget(
                dailyClaimReminders: _dailyClaimReminders,
                streakMilestoneAlerts: _streakMilestoneAlerts,
                referralNotifications: _referralNotifications,
                onDailyClaimChanged: (value) {
                  setState(() => _dailyClaimReminders = value);
                  _showConfirmation(
                    'Daily claim reminders ${value ? 'enabled' : 'disabled'}',
                  );
                },
                onStreakMilestoneChanged: (value) {
                  setState(() => _streakMilestoneAlerts = value);
                  _showConfirmation(
                    'Streak milestone alerts ${value ? 'enabled' : 'disabled'}',
                  );
                },
                onReferralChanged: (value) {
                  setState(() => _referralNotifications = value);
                  _showConfirmation(
                    'Referral notifications ${value ? 'enabled' : 'disabled'}',
                  );
                },
              ),

              SizedBox(height: 2.h),

              // Display Options
              DisplayOptionsWidget(
                balanceVisibility: _balanceVisibility,
                reducedMotion: _reducedMotion,
                timezoneFormat: _timezoneFormat,
                onBalanceVisibilityChanged: (value) {
                  setState(() => _balanceVisibility = value);
                  _showConfirmation(
                    'Balance visibility ${value ? 'enabled' : 'disabled'}',
                  );
                },
                onReducedMotionChanged: (value) {
                  setState(() => _reducedMotion = value);
                  _showConfirmation(
                    'Reduced motion ${value ? 'enabled' : 'disabled'}',
                  );
                },
                onTimezoneFormatChanged: (value) {
                  setState(() => _timezoneFormat = value);
                  _showConfirmation('Timezone format updated');
                },
              ),

              SizedBox(height: 2.h),

              // Security Section
              SecuritySectionWidget(
                biometricAuth: _biometricAuth,
                autoLogoutTiming: _autoLogoutTiming,
                onBiometricAuthChanged: (value) {
                  setState(() => _biometricAuth = value);
                  _showConfirmation(
                    'Biometric authentication ${value ? 'enabled' : 'disabled'}',
                  );
                },
                onAutoLogoutTimingChanged: (value) {
                  setState(() => _autoLogoutTiming = value);
                  _showConfirmation('Auto-logout timing updated');
                },
                onSessionManagement: _handleSessionManagement,
              ),

              SizedBox(height: 2.h),

              // Game Information
              GameInfoWidget(userData: _userData),

              SizedBox(height: 2.h),

              // Support Section
              SupportSectionWidget(
                appVersion: _userData["appVersion"] as String,
                onFaqPressed: _handleFaqAccess,
                onContactPressed: _handleContactSupport,
                onExportData: _handleDataExport,
              ),

              SizedBox(height: 2.h),

              // Legal Links
              _buildLegalSection(theme),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: BottomNavItem.me,
        onItemSelected: (item) {},
      ),
    );
  }

  Widget _buildLegalSection(ThemeData theme) {
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
            'Legal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildLegalItem(
            theme: theme,
            icon: 'description',
            title: 'Terms of Service',
            onTap: _handleTermsOfService,
          ),
          Divider(
            height: 3.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildLegalItem(
            theme: theme,
            icon: 'privacy_tip',
            title: 'Privacy Policy',
            onTap: _handlePrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem({
    required ThemeData theme,
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login-screen');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleSessionManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Management'),
        content: const Text(
          'All active sessions will be terminated except the current one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation('All other sessions terminated');
            },
            child: const Text('Terminate'),
          ),
        ],
      ),
    );
  }

  void _handleFaqAccess() {
    _showConfirmation('Opening FAQ section...');
  }

  void _handleContactSupport() {
    _showConfirmation('Opening contact support...');
  }

  void _handleDataExport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your transaction history will be downloaded as a CSV file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmation('Transaction history exported successfully');
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _handleTermsOfService() {
    _showConfirmation('Opening Terms of Service...');
  }

  void _handlePrivacyPolicy() {
    _showConfirmation('Opening Privacy Policy...');
  }
}

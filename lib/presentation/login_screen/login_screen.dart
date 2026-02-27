import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/device_id_display_widget.dart';
import './widgets/login_button_widget.dart';

/// Login Screen for device ID verification and biometric authentication
/// Provides secure re-authentication for returning users
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  String _deviceId = '';
  String _lastActiveTime = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDeviceInfo();
    _checkBiometricAvailability();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  Future<void> _loadDeviceInfo() async {
    // Simulate loading device ID from secure storage
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _deviceId =
            'NAVA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        _lastActiveTime =
            'Last active: ${_formatLastActive(DateTime.now().subtract(const Duration(hours: 3)))}';
      });
    }
  }

  String _formatLastActive(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate biometric availability check
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isBiometricAvailable = true;
      });
    }
  }

  Future<void> _handleBiometricAuth() async {
    if (!_isBiometricAvailable) return;

    setState(() => _isLoading = true);

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccessAndNavigate();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Biometric authentication failed. Please try again or use device ID.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeviceIdAuth() async {
    if (_deviceId.isEmpty) {
      _showErrorDialog('Device ID not found. Please register this device.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate device ID verification
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        HapticFeedback.lightImpact();
        _showSuccessAndNavigate();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          'Authentication failed. Please check your connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Welcome back! Authentication successful.'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Authentication Error',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleNewDevice() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 4.h,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 4.h),

                        // App Logo
                        _buildAppLogo(theme),

                        SizedBox(height: 6.h),

                        // Welcome Back Message
                        _buildWelcomeMessage(theme),

                        SizedBox(height: 2.h),

                        // Last Active Info
                        if (_lastActiveTime.isNotEmpty)
                          _buildLastActiveInfo(theme),

                        SizedBox(height: 4.h),

                        // Device ID Display
                        DeviceIdDisplayWidget(
                          deviceId: _deviceId,
                          isLoading: _deviceId.isEmpty,
                        ),

                        SizedBox(height: 4.h),

                        // Biometric Prompt
                        if (_isBiometricAvailable)
                          BiometricPromptWidget(
                            onBiometricPressed: _handleBiometricAuth,
                            isLoading: _isLoading,
                          ),

                        if (_isBiometricAvailable) SizedBox(height: 3.h),

                        // Continue Button
                        LoginButtonWidget(
                          onPressed: _handleDeviceIdAuth,
                          isLoading: _isLoading,
                        ),

                        SizedBox(height: 3.h),

                        // New Device Link
                        _buildNewDeviceLink(theme),

                        const Spacer(),

                        // Security Info
                        _buildSecurityInfo(theme),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: ClipOval(
          child: CustomImageWidget(
            imageUrl: 'assets/images/SQUARE-1767596263038.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Verify your device to continue',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLastActiveInfo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'access_time',
            size: 16,
            color: theme.colorScheme.tertiary,
          ),
          SizedBox(width: 2.w),
          Text(
            _lastActiveTime,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.tertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewDeviceLink(ThemeData theme) {
    return TextButton(
      onPressed: _isLoading ? null : _handleNewDevice,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New Device?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 1.w),
          CustomIconWidget(
            iconName: 'arrow_forward',
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'shield',
            size: 16,
            color: theme.colorScheme.tertiary,
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              'Your device ID is securely stored',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

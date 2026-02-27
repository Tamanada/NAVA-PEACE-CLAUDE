import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';

/// Splash Screen for NAVA PEACE token reward application
/// Handles app initialization, authentication check, and navigation routing
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitializing = true;
  String _statusMessage = 'Initializing...';
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isInitializing = true;
        _showRetry = false;
        _statusMessage = 'Initializing...';
      });

      // Simulate checking device ID authentication
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _statusMessage = 'Checking authentication...');

      // Simulate loading cached user data
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _statusMessage = 'Loading user data...');

      // Simulate fetching server configuration
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() => _statusMessage = 'Connecting to server...');

      // Simulate preparing token balance information
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _statusMessage = 'Preparing dashboard...');

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 400));

      // Determine navigation path based on authentication status
      await _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors
      setState(() {
        _isInitializing = false;
        _showRetry = true;
        _statusMessage = 'Connection failed. Please try again.';
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Simulate authentication check
    // In production, this would check actual device ID and user session
    final bool isAuthenticated = false; // Mock: user not authenticated
    final bool isNewUser = true; // Mock: new user

    // Smooth fade transition
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (isAuthenticated) {
      // Authenticated user -> Dashboard
      Navigator.pushReplacementNamed(context, '/dashboard-screen');
    } else if (isNewUser) {
      // New user -> Registration
      Navigator.pushReplacementNamed(context, '/registration-screen');
    } else {
      // Returning user -> Login
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  void _handleRetry() {
    _animationController.reset();
    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondary.withValues(alpha: 0.8),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Animated Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipOval(
                            child: CustomImageWidget(
                              imageUrl:
                                  'assets/images/SQUARE-1767596263038.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App Name
                      Text(
                        'NAVA PEACE',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'Daily Token Rewards',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // Loading Indicator and Status
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isInitializing) ...[
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    if (_showRetry) ...[
                      CustomIconWidget(
                        iconName: 'error_outline',
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'refresh',
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Retry',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 48),
                // Version Info
                Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

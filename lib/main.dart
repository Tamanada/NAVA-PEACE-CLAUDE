import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import './presentation/dashboard_screen/dashboard_screen.dart';
import './presentation/onboarding_screen/onboarding_screen.dart';
import './services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'NAVA PEACE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
          home: FutureBuilder<bool>(
            future: _checkOnboardingStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final needsOnboarding = snapshot.data ?? true;
              if (needsOnboarding) return const OnboardingScreen();
              return const DashboardScreen();
            },
          ),
          routes: AppRoutes.routes,
        );
      },
    );
  }

  Future<bool> _checkOnboardingStatus() async {
    try {
      final supabaseService = SupabaseService.instance;
      final userId = supabaseService.getCurrentUserId();

      if (userId == null) return true;

      final response = await supabaseService.client
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', userId)
          .single();

      return !(response['onboarding_completed'] as bool? ?? false);
    } catch (e) {
      return true;
    }
  }
}

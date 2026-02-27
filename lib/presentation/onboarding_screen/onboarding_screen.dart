import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/supabase_service.dart';
import './widgets/avatar_selection_widget.dart';
import './widgets/country_picker_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService.instance;

  String? _selectedCountry;
  String? _selectedGender;
  int? _selectedAge;
  String _peaceMessage = '';
  String _selectedAvatar = 'dove';
  bool _isAnonymous = false;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _avatarOptions = [
    'dove',
    'sun',
    'star',
    'olive_branch',
    'heart',
    'earth',
  ];

  final Map<String, IconData> _avatarIcons = {
    'dove': Icons.flutter_dash,
    'sun': Icons.wb_sunny,
    'star': Icons.star,
    'olive_branch': Icons.eco,
    'heart': Icons.favorite,
    'earth': Icons.public,
  };

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your country')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _supabaseService.getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      await _supabaseService.client
          .from('user_profiles')
          .update({
            'country': _selectedCountry,
            'gender': _selectedGender,
            'age': _selectedAge,
            'peace_message': _peaceMessage.trim().isEmpty
                ? null
                : _peaceMessage.trim(),
            'selected_avatar': _selectedAvatar,
            'is_anonymous': _isAnonymous,
            'onboarding_completed': true,
          })
          .eq('id', userId);

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF4EC2FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 2.h),

                // Logo and welcome message
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 30.w,
                        height: 30.w,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo_no_background-1767598321648.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Welcome to NAVA PEACE',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Join peace lovers around the world',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFF7F7F1),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Form container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Country picker
                      Text(
                        'Country of Origin',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF91A13F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CountryPickerWidget(
                        selectedCountry: _selectedCountry,
                        onCountrySelected: (country) {
                          setState(() => _selectedCountry = country);
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Gender selection
                      Text(
                        'Gender',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF91A13F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: _genderOptions.map((gender) {
                          final isSelected = _selectedGender == gender;
                          return FilterChip(
                            label: Text(gender),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(
                                () =>
                                    _selectedGender = selected ? gender : null,
                              );
                            },
                            backgroundColor: const Color(0xFFF7F7F1),
                            selectedColor: const Color(0xFF91A13F),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 2.h),

                      // Age input
                      Text(
                        'Age',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF91A13F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter your age',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 13 || age > 120) {
                            return 'Please enter a valid age (13-120)';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _selectedAge = int.tryParse(value);
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Peace message
                      Text(
                        'Your Message for Peace',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF91A13F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Share your message of peace...',
                          filled: true,
                          fillColor: const Color(0xFFF7F7F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        maxLines: 3,
                        maxLength: 200,
                        onChanged: (value) {
                          setState(() => _peaceMessage = value);
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Avatar selection
                      Text(
                        'Choose Your Avatar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF91A13F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      AvatarSelectionWidget(
                        selectedAvatar: _selectedAvatar,
                        avatarOptions: _avatarOptions,
                        avatarIcons: _avatarIcons,
                        onAvatarSelected: (avatar) {
                          setState(() => _selectedAvatar = avatar);
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Anonymous option
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Stay Anonymous',
                            style: theme.textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'Your identity will be hidden from other users',
                            style: theme.textTheme.bodySmall,
                          ),
                          value: _isAnonymous,
                          onChanged: (value) {
                            setState(() => _isAnonymous = value);
                          },
                          activeThumbColor: const Color(0xFF91A13F),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Submit button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF91A13F),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Join the Peace Movement',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

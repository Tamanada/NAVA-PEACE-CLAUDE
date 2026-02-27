import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/leaderboard_service.dart';
import './widgets/leaderboard_tab_widget.dart';
import './widgets/region_filter_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _leaderboardService = LeaderboardService();

  String? _selectedCountry;
  List<String> _availableCountries = [];
  bool _isLoadingCountries = true;

  final List<Map<String, String>> _categories = [
    {'id': 'daily_actions', 'title': 'Daily Actions'},
    {'id': 'total_tokens', 'title': 'Total Tokens'},
    {'id': 'streak_records', 'title': 'Streak Records'},
    {'id': 'badge_levels', 'title': 'Badge Levels'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _leaderboardService.getAvailableCountries();
      if (mounted) {
        setState(() {
          _availableCountries = ['All Regions', ...countries];
          _isLoadingCountries = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoadingCountries = false);
      }
    }
  }

  void _onCountryChanged(String? country) {
    setState(() {
      _selectedCountry = (country == 'All Regions') ? null : country;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Peace Leaderboard',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          tabs: _categories
              .map((category) => Tab(text: category['title']))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          RegionFilterWidget(
            selectedCountry: _selectedCountry ?? 'All Regions',
            availableCountries: _availableCountries,
            isLoading: _isLoadingCountries,
            onCountryChanged: _onCountryChanged,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return LeaderboardTabWidget(
                  category: category['id']!,
                  selectedCountry: _selectedCountry,
                  key: ValueKey('${category['id']}_$_selectedCountry'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

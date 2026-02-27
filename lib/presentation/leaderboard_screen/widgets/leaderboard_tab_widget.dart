import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/leaderboard_service.dart';
import '../../../services/supabase_service.dart';
import './ranking_list_item_widget.dart';
import './user_position_card_widget.dart';

class LeaderboardTabWidget extends StatefulWidget {
  final String category;
  final String? selectedCountry;

  const LeaderboardTabWidget({
    super.key,
    required this.category,
    this.selectedCountry,
  });

  @override
  State<LeaderboardTabWidget> createState() => _LeaderboardTabWidgetState();
}

class _LeaderboardTabWidgetState extends State<LeaderboardTabWidget> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _rankings = [];
  Map<String, dynamic>? _userRanking;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUserId = SupabaseService.instance.getCurrentUserId();

      final rankings = await _leaderboardService.getLeaderboard(
        category: widget.category,
        country: widget.selectedCountry,
        limit: 100,
      );

      Map<String, dynamic>? userRanking;
      if (currentUserId != null) {
        userRanking = await _leaderboardService.getUserRanking(
          userId: currentUserId,
          category: widget.category,
          country: widget.selectedCountry,
        );
      }

      if (mounted) {
        setState(() {
          _rankings = rankings;
          _userRanking = userRanking;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToUserPosition() {
    if (_userRanking == null) return;

    final rank = _userRanking!['rank'] as int;
    final itemHeight = 80.0;
    final offset = (rank - 1) * itemHeight;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  String _getCategoryLabel() {
    switch (widget.category) {
      case 'daily_actions':
        return 'Actions Completed';
      case 'total_tokens':
        return 'Tokens Earned';
      case 'streak_records':
        return 'Longest Streak';
      case 'badge_levels':
        return 'Badge Level';
      default:
        return 'Score';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            SizedBox(height: 2.h),
            Text(
              'Failed to load leaderboard',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rankings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 2.h),
            Text(
              'No rankings available yet',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Start contributing to peace to appear here!',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: Column(
        children: [
          if (_userRanking != null) ...[
            UserPositionCardWidget(
              ranking: _userRanking!,
              categoryLabel: _getCategoryLabel(),
              onFindMe: _scrollToUserPosition,
            ),
            const Divider(height: 1),
          ],
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 1.h),
              itemCount: _rankings.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, indent: 16.w, endIndent: 16.w),
              itemBuilder: (context, index) {
                final ranking = _rankings[index];
                final isCurrentUser =
                    _userRanking != null &&
                    ranking['user_id'] == _userRanking!['user_id'];

                return RankingListItemWidget(
                  ranking: ranking,
                  categoryLabel: _getCategoryLabel(),
                  isCurrentUser: isCurrentUser,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class UserPositionCardWidget extends StatelessWidget {
  final Map<String, dynamic> ranking;
  final String categoryLabel;
  final VoidCallback onFindMe;

  const UserPositionCardWidget({
    super.key,
    required this.ranking,
    required this.categoryLabel,
    required this.onFindMe,
  });

  String _formatValue(dynamic value, String category) {
    if (value == null) return '0';

    final numValue = value is num
        ? value
        : double.tryParse(value.toString()) ?? 0;

    switch (category) {
      case 'Total Tokens':
        return numValue.toStringAsFixed(2);
      case 'Badge Level':
        final badges = {
          1: 'Peace Lover',
          2: 'Peace Gardener',
          3: 'Peace Guide',
          4: 'Peace Guardian',
          5: 'Peace Illuminator',
          6: 'Peace Legend',
          7: 'Peace Angel',
        };
        return badges[numValue.toInt()] ?? 'Unknown';
      default:
        return numValue.toInt().toString();
    }
  }

  String _getAvatarEmoji(String avatarType) {
    switch (avatarType) {
      case 'dove':
        return '🕊️';
      case 'sun':
        return '☀️';
      case 'star':
        return '⭐';
      case 'olive_branch':
        return '🌿';
      case 'heart':
        return '❤️';
      case 'earth':
        return '🌍';
      default:
        return '🕊️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = ranking['rank'] as int;
    final userName = ranking['full_name'] as String? ?? 'You';
    final avatarType = ranking['selected_avatar'] as String? ?? 'dove';
    final value = ranking['value'];

    return Container(
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(179),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(77),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _getAvatarEmoji(avatarType),
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Position',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.yellow, size: 5.w),
                      SizedBox(width: 1.w),
                      Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatValue(value, categoryLabel),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: onFindMe,
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Find Me in List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class RankingListItemWidget extends StatelessWidget {
  final Map<String, dynamic> ranking;
  final String categoryLabel;
  final bool isCurrentUser;

  const RankingListItemWidget({
    super.key,
    required this.ranking,
    required this.categoryLabel,
    this.isCurrentUser = false,
  });

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.grey[400]!;
  }

  Widget _getRankBadge(int rank) {
    if (rank <= 3) {
      return Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: _getRankColor(rank),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getRankColor(rank).withAlpha(77),
              blurRadius: 8.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.emoji_events, color: Colors.white, size: 5.w),
        ),
      );
    }

    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final rank = ranking['rank'] as int;
    final userName = ranking['full_name'] as String? ?? 'Unknown User';
    final country = ranking['country'] as String? ?? '';
    final avatarType = ranking['selected_avatar'] as String? ?? 'dove';
    final value = ranking['value'];

    return Container(
      color: isCurrentUser
          ? Theme.of(context).primaryColor.withAlpha(26)
          : Colors.transparent,
      child: ListTile(
        leading: _getRankBadge(rank),
        title: Row(
          children: [
            Text(
              _getAvatarEmoji(avatarType),
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                userName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w500,
                  color: isCurrentUser
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: country.isNotEmpty
            ? Text(
                '🌍 $country',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatValue(value, categoryLabel),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isCurrentUser
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
            ),
            Text(
              categoryLabel,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

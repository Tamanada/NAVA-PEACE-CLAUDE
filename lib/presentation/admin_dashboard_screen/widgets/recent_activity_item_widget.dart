import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';


class RecentActivityItemWidget extends StatelessWidget {
  final Map<String, dynamic> activity;

  const RecentActivityItemWidget({super.key, required this.activity});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      case 'suspended':
        return const Color(0xFF9E9E9E);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return status.toUpperCase();
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('MMM d, HH:mm').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = activity['title'] ?? 'Unknown Place';
    final status = activity['status'] ?? 'pending';
    final timestamp = activity['created_at'];
    final userProfile = activity['user_profiles'];
    final submitterName = userProfile != null
        ? userProfile['full_name'] ?? 'Unknown User'
        : 'Unknown User';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(status).withAlpha(26),
        child: Icon(Icons.place, color: _getStatusColor(status), size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 0.5.h),
          Text(
            'Submitted by $submitterName',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.3.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withAlpha(26),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
      onTap: () {
        // Navigate to place details or moderation view
      },
    );
  }
}

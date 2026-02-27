import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';


class PlaceListItemWidget extends StatelessWidget {
  final Map<String, dynamic> place;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PlaceListItemWidget({
    super.key,
    required this.place,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

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

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = place['title'] ?? 'Unknown Place';
    final status = place['status'] ?? 'pending';
    final placeType = place['place_type'] ?? '';
    final city = place['city'] ?? '';
    final country = place['country'] ?? '';
    final timestamp = place['created_at'];
    final images = place['images'];
    final category = place['map_categories'];
    final categoryName = category != null ? category['name'] ?? '' : '';
    final userProfile = place['user_profiles'];
    final submitterName = userProfile != null
        ? userProfile['full_name'] ?? 'Unknown'
        : 'Unknown';

    final imageUrl = (images != null && images is List && images.isNotEmpty)
        ? images[0]
        : 'https://images.pexels.com/photos/3184287/pexels-photo-3184287.jpeg';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF91A13F).withAlpha(26)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: isSelected
              ? Border.all(color: const Color(0xFF91A13F), width: 2)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSelectionMode)
              Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF91A13F) : Colors.grey,
                  size: 24.sp,
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 20.w,
                height: 20.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 20.w,
                  height: 20.w,
                  color: Colors.grey[300],
                  child: const Icon(Icons.place, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withAlpha(26),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  if (categoryName.isNotEmpty)
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF91A13F),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12.sp, color: Colors.grey),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          '$city${city.isNotEmpty && country.isNotEmpty ? ', ' : ''}$country',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'By $submitterName • ${_formatDate(timestamp)}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isSelectionMode)
              Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

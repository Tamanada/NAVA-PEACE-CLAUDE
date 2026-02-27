import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/admin_service.dart';

class PlaceDetailModalWidget extends StatefulWidget {
  final Map<String, dynamic> place;
  final VoidCallback onActionComplete;

  const PlaceDetailModalWidget({
    super.key,
    required this.place,
    required this.onActionComplete,
  });

  @override
  State<PlaceDetailModalWidget> createState() => _PlaceDetailModalWidgetState();
}

class _PlaceDetailModalWidgetState extends State<PlaceDetailModalWidget> {
  bool _isProcessing = false;
  int _currentImageIndex = 0;

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);
    try {
      await AdminService.approvePlace(widget.place['id']);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Place approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onActionComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to approve: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Rejection'),
        content: const Text('Are you sure you want to reject this place?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      try {
        await AdminService.rejectPlace(widget.place['id']);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Place rejected'),
              backgroundColor: Colors.red,
            ),
          );
          widget.onActionComplete();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to reject: $e')));
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleSuspend() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Suspension'),
        content: const Text('Are you sure you want to suspend this place?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      try {
        await AdminService.suspendPlace(widget.place['id']);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Place suspended'),
              backgroundColor: Colors.orange,
            ),
          );
          widget.onActionComplete();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to suspend: $e')));
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.place['title'] ?? 'Unknown Place';
    final description = widget.place['description'] ?? '';
    final status = widget.place['status'] ?? 'pending';
    final placeType = widget.place['place_type'] ?? '';
    final city = widget.place['city'] ?? '';
    final country = widget.place['country'] ?? '';
    final address = widget.place['address_text'] ?? '';
    final images = widget.place['images'];
    final category = widget.place['map_categories'];
    final categoryName = category != null ? category['name'] ?? '' : '';
    final userProfile = widget.place['user_profiles'];
    final submitterName = userProfile != null
        ? userProfile['full_name'] ?? 'Unknown'
        : 'Unknown';
    final submitterEmail = userProfile != null
        ? userProfile['email'] ?? ''
        : '';

    final imageList = (images != null && images is List && images.isNotEmpty)
        ? List<String>.from(images)
        : ['https://images.pexels.com/photos/3184287/pexels-photo-3184287.jpeg'];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // Image Gallery
                  SizedBox(
                    height: 30.h,
                    child: PageView.builder(
                      itemCount: imageList.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageList[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.place,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                        );
                      },
                    ),
                  ),

                  // Image Indicator
                  if (imageList.length > 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imageList.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? const Color(0xFF4EC2FE)
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Place Details
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF91A13F).withAlpha(26),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF91A13F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        if (categoryName.isNotEmpty)
                          Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF4EC2FE),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        SizedBox(height: 2.h),

                        // Description
                        if (description.isNotEmpty) ...[
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],

                        // Location
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18.sp,
                              color: const Color(0xFF4EC2FE),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                address.isNotEmpty
                                    ? address
                                    : '$city, $country',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Submitter Info
                        Text(
                          'Submitted By',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.sp,
                              backgroundColor: const Color(0xFF4EC2FE),
                              child: Text(
                                submitterName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    submitterName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    submitterEmail,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // Action Buttons
                        if (status == 'pending') ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : _handleApprove,
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.5.h,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : _handleReject,
                                  icon: const Icon(Icons.close),
                                  label: const Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.5.h,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (status == 'approved') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _handleSuspend,
                              icon: const Icon(Icons.block),
                              label: const Text('Suspend Place'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

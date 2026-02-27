import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../models/map_place_model.dart';
import '../../services/map_service.dart';
import './widgets/contact_button_widget.dart';
import './widgets/image_gallery_widget.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final MapService _mapService = MapService();
  bool _isFavorited = false;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final place = ModalRoute.of(context)!.settings.arguments as MapPlaceModel?;
    if (place != null) {
      _checkFavoriteStatus(place.id);
    }
  }

  Future<void> _checkFavoriteStatus(String placeId) async {
    final isFavorited = await _mapService.isFavorited(placeId);
    setState(() {
      _isFavorited = isFavorited;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String placeId) async {
    try {
      await _mapService.toggleFavorite(placeId);
      setState(() => _isFavorited = !_isFavorited);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: const Color(0xFF91A13F),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorite status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReportDialog(BuildContext context, String placeId) {
    final reasonController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Place', style: GoogleFonts.inter(fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason',
                labelStyle: GoogleFonts.inter(fontSize: 13.sp),
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Additional Notes (Optional)',
                labelStyle: GoogleFonts.inter(fontSize: 13.sp),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              try {
                await _mapService.reportPlace(
                  placeId: placeId,
                  reason: reasonController.text,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted successfully'),
                    backgroundColor: Color(0xFF91A13F),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to submit report'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4EC2FE),
            ),
            child: Text(
              'Submit',
              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)!.settings.arguments as MapPlaceModel?;

    if (place == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Place not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.h,
            pinned: true,
            backgroundColor: const Color(0xFF4EC2FE),
            flexibleSpace: FlexibleSpaceBar(
              background: place.images.isNotEmpty
                  ? ImageGalleryWidget(images: place.images)
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.place,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
            actions: [
              if (!_isLoading)
                IconButton(
                  icon: Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _toggleFavorite(place.id),
                ),
              IconButton(
                icon: const Icon(Icons.flag, color: Colors.white),
                onPressed: () => _showReportDialog(context, place.id),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.title,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF91A13F).withAlpha(26),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          place.placeType.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF91A13F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (place.description != null) ...[
                    SizedBox(height: 16.h),
                    Text(
                      place.description!,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (place.tags.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: place.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: const Color(0xFF4EC2FE),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (place.addressText != null) ...[
                    SizedBox(height: 20.h),
                    _buildInfoRow(
                      Icons.location_on,
                      'Address',
                      place.addressText!,
                    ),
                  ],
                  if (place.city != null) ...[
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      Icons.location_city,
                      'City',
                      '${place.city}, ${place.country ?? ''}',
                    ),
                  ],
                  if (place.contact.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    Text(
                      'Contact Information',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (place.contact['phone'] != null)
                      ContactButtonWidget(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: place.contact['phone'] as String,
                        onTap: () =>
                            _launchUrl('tel:${place.contact['phone']}'),
                      ),
                    if (place.contact['whatsapp'] != null) ...[
                      SizedBox(height: 8.h),
                      ContactButtonWidget(
                        icon: Icons.chat,
                        label: 'WhatsApp',
                        value: place.contact['whatsapp'] as String,
                        onTap: () => _launchUrl(
                          'https://wa.me/${place.contact['whatsapp']}',
                        ),
                      ),
                    ],
                    if (place.contact['instagram'] != null) ...[
                      SizedBox(height: 8.h),
                      ContactButtonWidget(
                        icon: Icons.camera_alt,
                        label: 'Instagram',
                        value: place.contact['instagram'] as String,
                        onTap: () => _launchUrl(
                          'https://instagram.com/${place.contact['instagram']}',
                        ),
                      ),
                    ],
                    if (place.contact['website'] != null) ...[
                      SizedBox(height: 8.h),
                      ContactButtonWidget(
                        icon: Icons.language,
                        label: 'Website',
                        value: place.contact['website'] as String,
                        onTap: () =>
                            _launchUrl(place.contact['website'] as String),
                      ),
                    ],
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4EC2FE)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

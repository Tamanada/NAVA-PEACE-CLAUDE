import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/map_category_model.dart';

class MapFilterWidget extends StatelessWidget {
  final List<MapCategoryModel> categories;
  final String? selectedCategoryId;
  final String? selectedType;
  final Function({String? categoryId, String? type}) onFilterChanged;

  const MapFilterWidget({
    Key? key,
    required this.categories,
    this.selectedCategoryId,
    this.selectedType,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildCategoryFilter(context)),
          Container(width: 1, height: 30.h, color: Colors.grey.shade300),
          Expanded(child: _buildTypeFilter(context)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return PopupMenuButton<String?>(
      offset: Offset(0, 50.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, color: Color(0xFF4EC2FE), size: 20),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                selectedCategoryId != null
                    ? categories
                          .firstWhere((c) => c.id == selectedCategoryId)
                          .name
                    : 'Category',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4.w),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String?>(
          value: null,
          child: Text(
            'All Categories',
            style: GoogleFonts.inter(fontSize: 13.sp),
          ),
        ),
        ...categories.map(
          (category) => PopupMenuItem<String?>(
            value: category.id,
            child: Text(
              category.name,
              style: GoogleFonts.inter(fontSize: 13.sp),
            ),
          ),
        ),
      ],
      onSelected: (value) =>
          onFilterChanged(categoryId: value, type: selectedType),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    return PopupMenuButton<String?>(
      offset: Offset(0, 50.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_list, color: Color(0xFF4EC2FE), size: 20),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                selectedType ?? 'Type',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4.w),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String?>(
          value: null,
          child: Text('All Types', style: GoogleFonts.inter(fontSize: 13.sp)),
        ),
        PopupMenuItem<String?>(
          value: 'person',
          child: Text('Person', style: GoogleFonts.inter(fontSize: 13.sp)),
        ),
        PopupMenuItem<String?>(
          value: 'business',
          child: Text('Business', style: GoogleFonts.inter(fontSize: 13.sp)),
        ),
        PopupMenuItem<String?>(
          value: 'community',
          child: Text('Community', style: GoogleFonts.inter(fontSize: 13.sp)),
        ),
        PopupMenuItem<String?>(
          value: 'event',
          child: Text('Event', style: GoogleFonts.inter(fontSize: 13.sp)),
        ),
      ],
      onSelected: (value) =>
          onFilterChanged(categoryId: selectedCategoryId, type: value),
    );
  }
}
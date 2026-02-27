import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const ReportFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.list},
      {'key': 'pending', 'label': 'Pending', 'icon': Icons.pending},
      {'key': 'reviewed', 'label': 'Reviewed', 'icon': Icons.visibility},
      {'key': 'resolved', 'label': 'Resolved', 'icon': Icons.check_circle},
      {'key': 'dismissed', 'label': 'Dismissed', 'icon': Icons.cancel},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter['key'];
            return Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 4.w,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF4EC2FE),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      filter['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4EC2FE),
                      ),
                    ),
                  ],
                ),
                onSelected: (_) => onFilterChanged(filter['key'] as String),
                selectedColor: const Color(0xFF4EC2FE),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF4EC2FE)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

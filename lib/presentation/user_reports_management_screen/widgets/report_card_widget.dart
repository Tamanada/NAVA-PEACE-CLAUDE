import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReportCardWidget extends StatefulWidget {
  final Map<String, dynamic> report;
  final String priorityLevel;
  final Function(String) onAction;

  const ReportCardWidget({
    super.key,
    required this.report,
    required this.priorityLevel,
    required this.onAction,
  });

  @override
  State<ReportCardWidget> createState() => _ReportCardWidgetState();
}

class _ReportCardWidgetState extends State<ReportCardWidget> {
  bool _isExpanded = false;

  Color _getPriorityColor() {
    switch (widget.priorityLevel) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.report['map_places'] as Map<String, dynamic>?;
    final reporter = widget.report['user_profiles'] as Map<String, dynamic>?;
    final status = widget.report['status'] as String? ?? 'pending';

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      color: const Color(0xFFFFFFFF),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: _getPriorityColor(), width: 2),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(2.w),
            leading: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getPriorityColor().withAlpha(26),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.report_problem,
                color: _getPriorityColor(),
                size: 6.w,
              ),
            ),
            title: Text(
              widget.report['reason'] as String? ?? 'No reason provided',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 0.5.h),
                Text(
                  'Place: ${place?['title'] ?? 'Unknown place'}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Reported by: ${reporter?['full_name'] ?? 'Anonymous'}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatDate(widget.report['created_at'] as String?),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'pending'
                        ? Colors.orange.withAlpha(51)
                        : Colors.green.withAlpha(51),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: status == 'pending' ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 6.w,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1.h, thickness: 1),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details:',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    widget.report['notes'] as String? ??
                        'No additional details provided',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (status == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onAction('reviewed'),
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: Text(
                              'Review',
                              style: GoogleFonts.inter(fontSize: 11.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF91A13F),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onAction('resolved'),
                            icon: const Icon(Icons.done_all, size: 18),
                            label: Text(
                              'Resolve',
                              style: GoogleFonts.inter(fontSize: 11.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4EC2FE),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onAction('dismissed'),
                            icon: const Icon(Icons.close, size: 18),
                            label: Text(
                              'Dismiss',
                              style: GoogleFonts.inter(fontSize: 11.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

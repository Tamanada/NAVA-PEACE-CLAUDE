import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/map_service.dart';
import './widgets/report_card_widget.dart';
import './widgets/report_filter_widget.dart';
import './widgets/empty_reports_widget.dart';

class UserReportsManagementScreen extends StatefulWidget {
  const UserReportsManagementScreen({super.key});

  @override
  State<UserReportsManagementScreen> createState() =>
      _UserReportsManagementScreenState();
}

class _UserReportsManagementScreenState
    extends State<UserReportsManagementScreen> {
  final _mapService = MapService();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = false;
  String _selectedFilter = 'all'; // all, pending, reviewed, resolved, dismissed

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final isAdmin = await _mapService.isAdmin();
    if (!isAdmin && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Admin access required')));
    } else {
      _loadReports();
    }
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final status = _selectedFilter == 'all' ? null : _selectedFilter;
      final reports = await _mapService.getReports(status: status);
      if (mounted) {
        setState(() => _reports = reports);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load reports: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateReportStatus(String reportId, String status) async {
    try {
      await _mapService.updateReportStatus(reportId, status);
      _loadReports();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Report updated to $status')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update report: $e')));
      }
    }
  }

  String _getPriorityLevel(String reason) {
    final highPriority = ['spam', 'harassment', 'illegal'];
    final mediumPriority = ['inappropriate', 'misleading', 'copyright'];

    if (highPriority.any((p) => reason.toLowerCase().contains(p))) {
      return 'high';
    } else if (mediumPriority.any((p) => reason.toLowerCase().contains(p))) {
      return 'medium';
    }
    return 'low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4EC2FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4EC2FE),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'User Reports Management',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          ReportFilterWidget(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
              _loadReports();
            },
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reports.isEmpty
                  ? const EmptyReportsWidget()
                  : ListView.builder(
                      padding: EdgeInsets.all(3.w),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        return ReportCardWidget(
                          report: report,
                          priorityLevel: _getPriorityLevel(
                            report['reason'] as String? ?? '',
                          ),
                          onAction: (action) =>
                              _updateReportStatus(report['id'], action),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

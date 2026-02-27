import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/admin_service.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_action_tile_widget.dart';
import './widgets/recent_activity_item_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final stats = await AdminService.getDashboardStats();
      final activity = await AdminService.getRecentActivity(limit: 10);

      setState(() {
        _stats = stats;
        _recentActivity = activity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4EC2FE),
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: _buildSidebarDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
                  SizedBox(height: 2.h),
                  Text(_error, style: TextStyle(fontSize: 14.sp)),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: _loadDashboardData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key Metrics Section
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF91A13F),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildMetricsGrid(),
                    SizedBox(height: 3.h),

                    // Quick Actions Section
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF91A13F),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildQuickActionsGrid(),
                    SizedBox(height: 3.h),

                    // Recent Activity Section
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF91A13F),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildRecentActivityList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSidebarDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFFF0EDE4),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF4EC2FE)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'NAVA PEACE',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.place,
              title: 'Manage Places',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.placeManagementScreen);
              },
            ),
            _buildDrawerItem(
              icon: Icons.category,
              title: 'Categories',
              onTap: () {
                Navigator.pop(context);
                // Navigate to categories management (future implementation)
              },
            ),
            _buildDrawerItem(
              icon: Icons.report,
              title: 'User Reports',
              onTap: () {
                Navigator.pop(context);
                // Navigate to reports management (future implementation)
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Users',
              onTap: () {
                Navigator.pop(context);
                // Navigate to user management (future implementation)
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings (future implementation)
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF91A13F)),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp, color: Colors.black87),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 3.w,
      mainAxisSpacing: 2.h,
      childAspectRatio: 1.5,
      children: [
        MetricsCardWidget(
          title: 'Pending Places',
          value: _stats['pending_places']?.toString() ?? '0',
          icon: Icons.pending_actions,
          color: const Color(0xFFFF9800),
        ),
        MetricsCardWidget(
          title: 'Active Users',
          value: _stats['active_users']?.toString() ?? '0',
          icon: Icons.people,
          color: const Color(0xFF4EC2FE),
        ),
        MetricsCardWidget(
          title: 'Total Listings',
          value: _stats['total_listings']?.toString() ?? '0',
          icon: Icons.list_alt,
          color: const Color(0xFF91A13F),
        ),
        MetricsCardWidget(
          title: 'Flagged Content',
          value: _stats['flagged_content']?.toString() ?? '0',
          icon: Icons.flag,
          color: const Color(0xFFF44336),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 3.w,
      mainAxisSpacing: 2.h,
      childAspectRatio: 1.8,
      children: [
        QuickActionTileWidget(
          title: 'Review Places',
          icon: Icons.rate_review,
          color: const Color(0xFF4EC2FE),
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.placeManagementScreen);
          },
        ),
        QuickActionTileWidget(
          title: 'View Reports',
          icon: Icons.report_problem,
          color: const Color(0xFFF44336),
          onTap: () {
            // Navigate to reports (future implementation)
          },
        ),
        QuickActionTileWidget(
          title: 'Manage Categories',
          icon: Icons.category,
          color: const Color(0xFF91A13F),
          onTap: () {
            // Navigate to category management (future implementation)
          },
        ),
        QuickActionTileWidget(
          title: 'System Alerts',
          icon: Icons.notifications_active,
          color: const Color(0xFFFF9800),
          onTap: () {
            // Navigate to system alerts (future implementation)
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    if (_recentActivity.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Text(
            'No recent activity',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentActivity.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = _recentActivity[index];
          return RecentActivityItemWidget(activity: activity);
        },
      ),
    );
  }
}

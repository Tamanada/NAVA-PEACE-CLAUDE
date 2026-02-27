import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/admin_service.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/place_detail_modal_widget.dart';
import './widgets/place_list_item_widget.dart';

class PlaceManagementScreen extends StatefulWidget {
  const PlaceManagementScreen({super.key});

  @override
  State<PlaceManagementScreen> createState() => _PlaceManagementScreenState();
}

class _PlaceManagementScreenState extends State<PlaceManagementScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Map<String, dynamic>> _places = [];
  String _selectedStatus = 'pending';
  String? _selectedCategory;
  String _searchQuery = '';
  final Set<String> _selectedPlaceIds = {};
  bool _bulkSelectMode = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final places = await AdminService.getPlacesForManagement(
        statusFilter: _selectedStatus,
        categoryId: _selectedCategory,
        searchQuery: _searchQuery,
      );

      setState(() {
        _places = places;
        _isLoading = false;
        _selectedPlaceIds.clear();
        _bulkSelectMode = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBulkApprove() async {
    if (_selectedPlaceIds.isEmpty) return;

    try {
      await AdminService.bulkApprovePlaces(_selectedPlaceIds.toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedPlaceIds.length} places approved'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPlaces();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to approve places: $e')));
      }
    }
  }

  Future<void> _handleBulkReject() async {
    if (_selectedPlaceIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Rejection'),
        content: Text('Reject ${_selectedPlaceIds.length} selected places?'),
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
      try {
        await AdminService.bulkRejectPlaces(_selectedPlaceIds.toList());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedPlaceIds.length} places rejected'),
              backgroundColor: Colors.red,
            ),
          );
          _loadPlaces();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reject places: $e')),
          );
        }
      }
    }
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PlaceDetailModalWidget(place: place, onActionComplete: _loadPlaces),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4EC2FE),
        title: Text(
          'Place Management',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_bulkSelectMode)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _bulkSelectMode = false;
                  _selectedPlaceIds.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.checklist, color: Colors.white),
              onPressed: () {
                setState(() {
                  _bulkSelectMode = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(3.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadPlaces();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF0EDE4),
              ),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadPlaces();
              },
            ),
          ),

          // Filter Chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipWidget(
                    label: 'Pending',
                    isSelected: _selectedStatus == 'pending',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'pending';
                      });
                      _loadPlaces();
                    },
                  ),
                  SizedBox(width: 2.w),
                  FilterChipWidget(
                    label: 'Approved',
                    isSelected: _selectedStatus == 'approved',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'approved';
                      });
                      _loadPlaces();
                    },
                  ),
                  SizedBox(width: 2.w),
                  FilterChipWidget(
                    label: 'Rejected',
                    isSelected: _selectedStatus == 'rejected',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'rejected';
                      });
                      _loadPlaces();
                    },
                  ),
                  SizedBox(width: 2.w),
                  FilterChipWidget(
                    label: 'Suspended',
                    isSelected: _selectedStatus == 'suspended',
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'suspended';
                      });
                      _loadPlaces();
                    },
                  ),
                  SizedBox(width: 2.w),
                  FilterChipWidget(
                    label: 'All',
                    isSelected: _selectedStatus == '',
                    onTap: () {
                      setState(() {
                        _selectedStatus = '';
                      });
                      _loadPlaces();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bulk Action Bar
          if (_bulkSelectMode && _selectedPlaceIds.isNotEmpty)
            Container(
              color: const Color(0xFF91A13F).withAlpha(26),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Row(
                children: [
                  Text(
                    '${_selectedPlaceIds.length} selected',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _handleBulkApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton.icon(
                    onPressed: _handleBulkReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Places List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 50.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 2.h),
                        Text(_error, style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: _loadPlaces,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _places.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60.sp, color: Colors.grey),
                        SizedBox(height: 2.h),
                        Text(
                          'No places found',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPlaces,
                    child: ListView.builder(
                      padding: EdgeInsets.all(3.w),
                      itemCount: _places.length,
                      itemBuilder: (context, index) {
                        final place = _places[index];
                        final placeId = place['id'];
                        final isSelected = _selectedPlaceIds.contains(placeId);

                        return PlaceListItemWidget(
                          place: place,
                          isSelectionMode: _bulkSelectMode,
                          isSelected: isSelected,
                          onTap: () {
                            if (_bulkSelectMode) {
                              setState(() {
                                if (isSelected) {
                                  _selectedPlaceIds.remove(placeId);
                                } else {
                                  _selectedPlaceIds.add(placeId);
                                }
                              });
                            } else {
                              _showPlaceDetails(place);
                            }
                          },
                          onLongPress: () {
                            if (!_bulkSelectMode) {
                              setState(() {
                                _bulkSelectMode = true;
                                _selectedPlaceIds.add(placeId);
                              });
                            }
                          },
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

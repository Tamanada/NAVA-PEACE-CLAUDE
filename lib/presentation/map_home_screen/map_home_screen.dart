import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/map_category_model.dart';
import '../../models/map_place_model.dart';
import '../../models/user_location_stat_model.dart';
import '../../services/map_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/map_filter_widget.dart';
import './widgets/map_search_bar_widget.dart';
import './widgets/place_info_bottom_sheet_widget.dart';

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<MapPlaceModel> _places = [];
  List<UserLocationStatModel> _userLocations = [];
  List<MapCategoryModel> _categories = [];
  String? _selectedCategoryId;
  String? _selectedType;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showUserLocations = true;
  Position? _currentPosition;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.0, 0.0), // World center view
    zoom: 2.5,
  );

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUserLocationStats();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      // Silent fail for location
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _mapService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadUserLocationStats() async {
    try {
      final stats = await _mapService.getUserLocationStats();
      setState(() => _userLocations = stats);
      _updateAllMarkers();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadPlacesInView() async {
    if (_mapController == null) return;

    setState(() => _isLoading = true);

    try {
      final bounds = await _mapController!.getVisibleRegion();

      final places = await _mapService.getPlacesInBbox(
        minLat: bounds.southwest.latitude,
        minLng: bounds.southwest.longitude,
        maxLat: bounds.northeast.latitude,
        maxLng: bounds.northeast.longitude,
        categoryId: _selectedCategoryId,
        placeType: _selectedType,
        searchText: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _places = places;
        _isLoading = false;
      });
      _updateAllMarkers();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateAllMarkers() {
    final markers = <Marker>{};

    // Add place markers
    for (final place in _places) {
      markers.add(
        Marker(
          markerId: MarkerId('place_${place.id}'),
          position: LatLng(place.lat, place.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(place.placeType),
          ),
          infoWindow: InfoWindow(
            title: place.title,
            snippet: place.description ?? '',
            onTap: () => _showPlaceDetails(place),
          ),
          onTap: () => _showPlaceInfoSheet(place),
        ),
      );
    }

    // Add user location markers if enabled
    if (_showUserLocations) {
      for (final location in _userLocations) {
        if (location.lat != 0.0 && location.lng != 0.0) {
          markers.add(
            Marker(
              markerId: MarkerId('users_${location.country}'),
              position: LatLng(location.lat, location.lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              ),
              infoWindow: InfoWindow(
                title: '${location.country}',
                snippet:
                    '${location.userCount} peace lover${location.userCount > 1 ? 's' : ''}',
              ),
              alpha: 0.8,
            ),
          );
        }
      }
    }

    setState(() => _markers = markers);
  }

  double _getMarkerColor(String type) {
    switch (type) {
      case 'business':
        return BitmapDescriptor.hueBlue;
      case 'event':
        return BitmapDescriptor.hueGreen;
      case 'community':
        return BitmapDescriptor.hueOrange;
      case 'person':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _showPlaceInfoSheet(MapPlaceModel place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceInfoBottomSheetWidget(
        place: place,
        onViewDetails: () {
          Navigator.pop(context);
          _showPlaceDetails(place);
        },
      ),
    );
  }

  void _showPlaceDetails(MapPlaceModel place) {
    Navigator.pushNamed(
      context,
      AppRoutes.placeDetailsScreen,
      arguments: place,
    );
  }

  void _applyFilters({String? categoryId, String? type}) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedType = type;
    });
    _loadPlacesInView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4EC2FE),
        elevation: 0,
        title: Text(
          'NAVA PEACE Map',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showUserLocations ? Icons.people : Icons.people_outline,
              color: Colors.white,
            ),
            tooltip: 'Toggle Peace Lovers',
            onPressed: () {
              setState(() => _showUserLocations = !_showUserLocations);
              _updateAllMarkers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.add_location, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.addPlaceScreen),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _loadPlacesInView();
            },
            onCameraIdle: _loadPlacesInView,
          ),
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MapSearchBarWidget(
                  onSearch: (query) {
                    setState(() => _searchQuery = query);
                    _loadPlacesInView();
                  },
                ),
                SizedBox(height: 12.h),
                MapFilterWidget(
                  categories: _categories,
                  selectedCategoryId: _selectedCategoryId,
                  selectedType: _selectedType,
                  onFilterChanged: _applyFilters,
                ),
              ],
            ),
          ),
          if (_showUserLocations && _userLocations.isNotEmpty)
            Positioned(
              bottom: 90.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF91A13F).withAlpha(230),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 16),
                    SizedBox(width: 6.w),
                    Text(
                      '${_userLocations.fold<int>(0, (sum, loc) => sum + loc.userCount)} peace lovers worldwide',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            Positioned(
              top: 120.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF4EC2FE),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading places...',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addPlaceScreen),
        backgroundColor: const Color(0xFF4EC2FE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: BottomNavItem.worldMap,
        onItemSelected: (item) {},
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

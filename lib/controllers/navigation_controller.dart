import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../model/navigation_models.dart';
import '../services/map_service.dart';

enum LocationPermissionStatus {
  serviceDisabled,
  denied,
  deniedForever,
  granted,
}

class NavigationController extends ChangeNotifier {
  final MapService _mapService = MapService();

  // Location and navigation state
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  RouteInfo? _currentRoute;
  bool _isNavigationActive = false;
  bool _isNavigationMode = false;
  int _currentStepIndex = 0;
  StreamSubscription<Position>? _locationSubscription;

  // Map markers and polylines
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Getters
  LatLng? get currentPosition => _currentPosition;
  LatLng? get destinationPosition => _destinationPosition;
  RouteInfo? get currentRoute => _currentRoute;
  bool get isNavigationActive => _isNavigationActive;
  bool get isNavigationMode => _isNavigationMode;
  int get currentStepIndex => _currentStepIndex;
  Set<Marker> get markers => Set.from(_markers);
  Set<Polyline> get polylines => Set.from(_polylines);
  
  NavStep? get currentStep {
    if (_currentRoute == null || 
        _currentStepIndex >= _currentRoute!.navSteps.length) {
      return null;
    }
    return _currentRoute!.navSteps[_currentStepIndex];
  }

  /// Initialize the controller
  Future<void> initialize() async {
    await _mapService.loadCustomIcons();
    await _getCurrentLocation();
  }

  /// Get current location (no custom dialogs - let system handle it)
  Future<void> _getCurrentLocation({bool requestIfNeeded = false}) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Only request permission if explicitly requested and not denied forever
      if (requestIfNeeded && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied by user');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      // Get current position if permission is granted
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        final position = await _mapService.getCurrentLocation();
        _currentPosition = position;
        _updateCurrentLocationMarker();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  /// Check location permission status
  Future<LocationPermissionStatus> checkLocationPermissionStatus() async {
    // First check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Then check permission
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    } else if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    } else if (permission == LocationPermission.whileInUse || 
               permission == LocationPermission.always) {
      return LocationPermissionStatus.granted;
    }
    
    return LocationPermissionStatus.denied;
  }

  /// Request location permission (triggers system dialog)
  Future<bool> requestLocationPermission() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled. Attempting to trigger system prompt.');
        // Try to get current position which can trigger system dialog to enable location
        try {
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          // If successful, check again if services are enabled
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (serviceEnabled) {
            debugPrint('Location services were enabled');
            // Continue to check and request permission
          } else {
            debugPrint('Location services still disabled');
            return false;
          }
        } catch (e) {
          debugPrint('Error getting current position: $e');
          return false;
        }
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      
      // If already granted, return true
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        await refreshLocation();
        return true;
      }
      
      // Always request permission to show native dialog
      // Even if denied or denied forever, try to request
      debugPrint('Requesting location permission...');
      permission = await Geolocator.requestPermission();
      
      debugPrint('Permission result: $permission');
      
      // Check result
      bool granted = permission == LocationPermission.whileInUse || 
                     permission == LocationPermission.always;
      
      // If granted, refresh location
      if (granted) {
        await refreshLocation();
      }
      
      return granted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Refresh location continuously
  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  /// Open system location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Update current location marker
  void _updateCurrentLocationMarker() {
    if (_currentPosition == null) return;

    _markers.removeWhere((marker) => marker.markerId.value == 'current');
    _markers.add(
      Marker(
        markerId: const MarkerId('current'),
        position: _currentPosition!,
        icon: _mapService.userIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );
  }

  /// Set destination and calculate route
  Future<void> setDestination(LatLng destination) async {
    if (_currentPosition == null) return;

    _destinationPosition = destination;
    
    // Add destination marker
    _markers.removeWhere((marker) => marker.markerId.value == 'destination');
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: _mapService.destinationIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );

    // Calculate route
    final route = await _mapService.getRoute(_currentPosition!, destination);
    if (route != null) {
      _currentRoute = route;
      _updatePolyline();
    }

    notifyListeners();
  }

  /// Update polyline on map
  void _updatePolyline() {
    if (_currentRoute == null) return;

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: _currentRoute!.polylinePoints,
        color: Colors.purple,
        width: 7,
      ),
    );
  }

  /// Start navigation
  Future<void> startNavigation() async {
    if (_destinationPosition == null || _isNavigationActive) return;

    // Check location permission before starting navigation
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint('Location permission required for navigation');
      return;
    }

    _isNavigationActive = true;
    _isNavigationMode = true;
    _currentStepIndex = 0;

    // Start listening for location updates
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (Position newPosition) {
        _currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
        _updateCurrentLocationMarker();
        _checkArrival();
        _advanceStepIfReached();
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Location stream error: $e");
      },
    );

    notifyListeners();
  }

  /// Stop navigation
  void stopNavigation() {
    _isNavigationActive = false;
    _isNavigationMode = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    notifyListeners();
  }

  /// Check if user has arrived at destination
  void _checkArrival() {
    if (_destinationPosition == null || _currentPosition == null) return;

    double distance = _mapService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _destinationPosition!.latitude,
      _destinationPosition!.longitude,
    ) * 1000; // Convert to meters

    // Check if distance is less than 50 meters (arrival threshold)
    if (distance < 50) {
      stopNavigation();
      // You can add arrival callback here
    }
  }

  /// Advance to next step if current step is reached
  void _advanceStepIfReached() {
    if (_currentRoute == null ||
        _currentStepIndex >= _currentRoute!.navSteps.length ||
        _currentPosition == null) {
      return;
    }

    final currentStep = _currentRoute!.navSteps[_currentStepIndex];
    final distance = _mapService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      currentStep.end.latitude,
      currentStep.end.longitude,
    ) * 1000; // Convert to meters

    if (distance < 25) {
      _currentStepIndex = (_currentStepIndex + 1)
          .clamp(0, _currentRoute!.navSteps.length - 1);
    }
  }

  /// Add station markers
  void addStationMarkers(Set<Marker> stationMarkers) {
    // Remove existing station markers
    _markers.removeWhere((marker) => 
        marker.markerId.value.startsWith('station_'));
    
    // Add new station markers
    _markers.addAll(stationMarkers);
    notifyListeners();
  }

  /// Clear route
  void clearRoute() {
    _destinationPosition = null;
    _currentRoute = null;
    _polylines.clear();
    _markers.removeWhere((marker) => marker.markerId.value == 'destination');
    notifyListeners();
  }

  /// Get camera bounds for current route
  LatLngBounds? getRouteBounds() {
    if (_currentPosition == null || _destinationPosition == null) return null;
    return _mapService.createBounds(_currentPosition!, _destinationPosition!);
  }

  /// Update map bounds for all stations
  void updateMapBounds(LatLngBounds bounds) {
    // This will be used by the map widget to update camera position
    // The actual implementation will be handled by the map widget
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

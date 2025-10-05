import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../model/navigation_models.dart';
import '../const/google_api.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  BitmapDescriptor? _userIcon;
  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _stationIcon;

  /// Load custom marker icons
  Future<void> loadCustomIcons() async {
    _userIcon = await _getCustomMarker(
      'asset/home/User icon 2 (1).png',
      size: 120,
    );
    
    _destinationIcon = await _getCustomMarker(
      'asset/home/Battery station icon (1).png',
      size: 120,
    );
    
    _stationIcon = await _getCustomMarker(
      'asset/home/Battery station icon (1).png',
      size: 100,
    );
  }

  /// Get custom marker from asset
  Future<BitmapDescriptor> _getCustomMarker(
    String path, {
    int size = 120,
  }) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final codec = await instantiateImageCodec(bytes, targetWidth: size);
    final frame = await codec.getNextFrame();
    final newBytes = await frame.image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(newBytes!.buffer.asUint8List());
  }

  /// Get current location
  Future<LatLng> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }

  /// Calculate bearing from point A to B (degrees)
  double bearingBetween(LatLng from, LatLng to) {
    final lat1 = _degToRad(from.latitude);
    final lon1 = _degToRad(from.longitude);
    final lat2 = _degToRad(to.latitude);
    final lon2 = _degToRad(to.longitude);
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    var brng = _radToDeg(math.atan2(y, x));
    return (brng + 360) % 360;
  }

  double _degToRad(double deg) => deg * (3.141592653589793 / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / 3.141592653589793);

  /// Get route between two points
  Future<RouteInfo?> getRoute(LatLng start, LatLng end) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$googleApiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      debugPrint('Directions API error: ${response.statusCode}');
      return null;
    }

    final data = json.decode(response.body);

    if (data['routes'] == null || data['routes'].isEmpty) {
      debugPrint('No routes found between start and end.');
      return null;
    }

    final route = data['routes'][0];
    final encodedPoints = route['overview_polyline']['points'];
    final polylinePoints = _decodePoly(encodedPoints);

    // Parse turn-by-turn steps
    final List<NavStep> steps = [];
    int totalDurationMinutes = 0;
    double totalDistanceKm = 0.0;
    
    try {
      if (route['legs'] != null && route['legs'].isNotEmpty) {
        final leg = route['legs'][0];
        
        // Get total duration and distance from the leg
        if (leg['duration'] != null) {
          totalDurationMinutes = (leg['duration']['value'] / 60).round();
        }
        if (leg['distance'] != null) {
          totalDistanceKm = leg['distance']['value'] / 1000.0;
        }
        
        // Parse individual steps
        final legSteps = leg['steps'] as List<dynamic>;
        for (final s in legSteps) {
          steps.add(NavStep.fromJson(s));
        }
      }
    } catch (e) {
      debugPrint('Failed parsing steps: $e');
    }

    // Fallback to calculated distance if API doesn't provide it
    if (totalDistanceKm == 0.0) {
      totalDistanceKm = calculateDistance(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    }

    // Fallback to estimated time if API doesn't provide it
    if (totalDurationMinutes == 0) {
      totalDurationMinutes = (totalDistanceKm * 2).round(); // Rough estimate
    }

    return RouteInfo(
      polylinePoints: polylinePoints,
      navSteps: steps,
      distanceKm: totalDistanceKm,
      durationMinutes: totalDurationMinutes,
    );
  }

  /// Decode polyline points
  List<LatLng> _decodePoly(String encoded) {
    var list = <LatLng>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      list.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return list;
  }

  /// Create bounds for two points
  LatLngBounds createBounds(LatLng a, LatLng b) {
    return LatLngBounds(
      southwest: LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      northeast: LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );
  }

  /// Get icon for maneuver
  IconData getManeuverIcon(String? maneuver) {
    if (maneuver == null) return Icons.navigation;
    switch (maneuver) {
      case 'turn-left':
        return Icons.turn_left;
      case 'turn-right':
        return Icons.turn_right;
      case 'turn-slight-left':
        return Icons.turn_slight_left;
      case 'turn-slight-right':
        return Icons.turn_slight_right;
      case 'turn-sharp-left':
        return Icons.turn_sharp_left;
      case 'turn-sharp-right':
        return Icons.turn_sharp_right;
      case 'uturn-left':
      case 'uturn-right':
        return Icons.u_turn_left;
      case 'roundabout-left':
      case 'roundabout-right':
        return Icons.roundabout_left;
      case 'merge':
        return Icons.merge;
      case 'fork-left':
      case 'fork-right':
        return Icons.fork_left;
      case 'ramp-left':
      case 'ramp-right':
        return Icons.ramp_left;
      default:
        return Icons.navigation;
    }
  }

  // Getters for icons
  BitmapDescriptor? get userIcon => _userIcon;
  BitmapDescriptor? get destinationIcon => _destinationIcon;
  BitmapDescriptor? get stationIcon => _stationIcon;
}

import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/navigation_models.dart';
import 'map_service.dart';

class StationService {
  static final StationService _instance = StationService._internal();
  factory StationService() => _instance;
  StationService._internal();

  final MapService _mapService = MapService();

  /// Generate dummy stations within specified radius (in km)
  List<DestinationStation> generateDummyStations(
    LatLng currentPosition, {
    int count = 10,
    double radiusKm = 10.0,
  }) {
    final random = math.Random();
    final List<DestinationStation> stations = [];

    // Convert km to degrees (approximate: 1 degree ≈ 111km)
    final double radiusInDegrees = radiusKm / 111.0;

    for (int i = 0; i < count; i++) {
      // Generate random coordinates within radius
      final double angle = random.nextDouble() * 2 * math.pi;
      final double distance = random.nextDouble() * radiusInDegrees;

      final double lat = currentPosition.latitude + (distance * math.cos(angle));
      final double lng = currentPosition.longitude + (distance * math.sin(angle));

      final stationPosition = LatLng(lat, lng);
      final distanceKm = _mapService.calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        lat,
        lng,
      );

      final station = DestinationStation(
        id: 'station_$i',
        name: 'SwapStation ${String.fromCharCode(65 + i)}', // A, B, C, etc.
        position: stationPosition,
        type: i % 2 == 0 ? 'Fast Charge' : 'Standard',
        availableSlots: random.nextInt(8) + 1, // 1-8 slots
        distanceKm: distanceKm,
      );

      stations.add(station);
    }

    // Sort by distance
    stations.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

    return stations;
  }

  /// Create markers for stations
  Set<Marker> createStationMarkers(
    List<DestinationStation> stations,
    Function(DestinationStation) onTap,
  ) {
    final Set<Marker> markers = {};

    for (final station in stations) {
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: station.position,
          icon: _mapService.stationIcon ?? 
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () => onTap(station),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: '${station.type} • ${station.availableSlots} slots',
          ),
        ),
      );
    }

    return markers;
  }

  /// Find nearest station to a position
  DestinationStation? findNearestStation(
    List<DestinationStation> stations,
    LatLng position,
  ) {
    if (stations.isEmpty) return null;

    DestinationStation? nearest;
    double minDistance = double.infinity;

    for (final station in stations) {
      final distance = _mapService.calculateDistance(
        position.latitude,
        position.longitude,
        station.position.latitude,
        station.position.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = station.copyWith(distanceKm: distance);
      }
    }

    return nearest;
  }

  /// Filter stations by criteria
  List<DestinationStation> filterStations(
    List<DestinationStation> stations, {
    String? type,
    int? minAvailableSlots,
    double? maxDistanceKm,
  }) {
    return stations.where((station) {
      if (type != null && station.type != type) return false;
      if (minAvailableSlots != null && station.availableSlots < minAvailableSlots) return false;
      if (maxDistanceKm != null && (station.distanceKm ?? 0) > maxDistanceKm) return false;
      return true;
    }).toList();
  }

  /// Simulate booking a station
  Future<bool> bookStation(DestinationStation station) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate 90% success rate
    return math.Random().nextDouble() > 0.1;
  }

  /// Get station types
  List<String> getStationTypes() {
    return ['Fast Charge', 'Standard'];
  }
}

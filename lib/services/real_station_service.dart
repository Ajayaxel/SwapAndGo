import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/station_model.dart';
import '../model/navigation_models.dart';
import 'map_service.dart';

class RealStationService {
  static final RealStationService _instance = RealStationService._internal();
  factory RealStationService() => _instance;
  RealStationService._internal();

  final MapService _mapService = MapService();

  /// Convert Station model to DestinationStation for Google Maps
  DestinationStation convertToDestinationStation(
    Station station,
    LatLng? currentPosition,
  ) {
    double? distanceKm;
    
    if (currentPosition != null) {
      distanceKm = _mapService.calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        station.position.latitude,
        station.position.longitude,
      );
    }

    return DestinationStation(
      id: station.id,
      name: station.name,
      position: station.position,
      type: station.type,
      availableSlots: station.availableSlots,
      distanceKm: distanceKm,
    );
  }

  /// Convert list of Station models to DestinationStation list
  List<DestinationStation> convertToDestinationStations(
    List<Station> stations,
    LatLng? currentPosition,
  ) {
    final List<DestinationStation> destinationStations = stations
        .map((station) => convertToDestinationStation(station, currentPosition))
        .toList();

    // Sort by distance if current position is available
    if (currentPosition != null) {
      destinationStations.sort((a, b) => 
          (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    }

    return destinationStations;
  }

  /// Create markers for real stations
  Set<Marker> createStationMarkers(
    List<Station> stations,
    Function(Station) onTap,
  ) {
    final Set<Marker> markers = {};

    for (final station in stations) {
      // Choose marker color based on availability
      BitmapDescriptor markerIcon;
      if (station.availableSlots == 0) {
        markerIcon = _mapService.stationIcon ?? 
                    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else if (station.availableSlots <= 2) {
        markerIcon = _mapService.stationIcon ?? 
                    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      } else {
        markerIcon = _mapService.stationIcon ?? 
                    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      }

      markers.add(
        Marker(
          markerId: MarkerId('station_${station.id}'),
          position: station.position,
          icon: markerIcon,
          onTap: () => onTap(station),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: '${station.type} • ${station.availableSlots}/${station.capacity} slots • ${station.is24x7 ? "24/7" : "Limited hours"}',
          ),
        ),
      );
    }

    return markers;
  }

  /// Find nearest station to a position
  Station? findNearestStation(
    List<Station> stations,
    LatLng position,
  ) {
    if (stations.isEmpty) return null;

    Station? nearest;
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
        nearest = station;
      }
    }

    return nearest;
  }

  /// Filter stations by criteria
  List<Station> filterStations(
    List<Station> stations, {
    String? type,
    int? minAvailableSlots,
    double? maxDistanceKm,
    LatLng? currentPosition,
    bool? is24x7,
    bool? isActive,
  }) {
    return stations.where((station) {
      if (type != null && station.type != type) return false;
      if (minAvailableSlots != null && station.availableSlots < minAvailableSlots) return false;
      if (is24x7 != null && station.is24x7 != is24x7) return false;
      if (isActive != null && station.isActive != isActive) return false;
      
      if (maxDistanceKm != null && currentPosition != null) {
        final distance = _mapService.calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          station.position.latitude,
          station.position.longitude,
        );
        if (distance > maxDistanceKm) return false;
      }
      
      return true;
    }).toList();
  }

  /// Get route between current position and station with real-time data
  Future<RouteInfo?> getRouteToStation(
    LatLng currentPosition,
    Station station,
  ) async {
    return await _mapService.getRoute(currentPosition, station.position);
  }

  /// Calculate real-time distance and estimated travel time
  Future<Map<String, dynamic>> getStationInfo(
    LatLng currentPosition,
    Station station,
  ) async {
    // Get route for more accurate distance and time estimation
    final route = await getRouteToStation(currentPosition, station);
    
    double distance;
    int estimatedMinutes;
    
    if (route != null) {
      distance = route.distanceKm;
      estimatedMinutes = route.durationMinutes;
    } else {
      // Fallback: calculate straight-line distance and estimate time
      distance = _mapService.calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        station.position.latitude,
        station.position.longitude,
      );
      // Estimate time based on distance (average speed 30 km/h)
      estimatedMinutes = (distance * 2).round();
    }

    return {
      'distance': distance,
      'estimatedTime': estimatedMinutes,
      'station': station,
      'route': route,
    };
  }

  /// Calculate distance between two points
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return _mapService.calculateDistance(startLat, startLng, endLat, endLng);
  }
}

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Navigation step model for turn-by-turn directions
class NavStep {
  final LatLng end;
  final String instruction;
  final String? maneuver;
  final int distanceMeters;

  NavStep({
    required this.end,
    required this.instruction,
    required this.maneuver,
    required this.distanceMeters,
  });

  factory NavStep.fromJson(Map<String, dynamic> json) {
    final endLoc = json['end_location'];
    final instructionHtml = (json['html_instructions'] ?? '').toString();
    final maneuver = json['maneuver']?.toString();
    final distanceMeters = (json['distance']?['value'] ?? 0) as int;

    return NavStep(
      end: LatLng(
        (endLoc['lat'] as num).toDouble(),
        (endLoc['lng'] as num).toDouble(),
      ),
      instruction: _stripHtmlTags(instructionHtml),
      maneuver: maneuver,
      distanceMeters: distanceMeters,
    );
  }

  static String _stripHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r"<[^>]*>"), '');
  }
}

/// Destination station model
class DestinationStation {
  final String id;
  final String name;
  final LatLng position;
  final String type;
  final int availableSlots;
  final double? distanceKm;

  DestinationStation({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    required this.availableSlots,
    this.distanceKm,
  });

  DestinationStation copyWith({
    String? id,
    String? name,
    LatLng? position,
    String? type,
    int? availableSlots,
    double? distanceKm,
  }) {
    return DestinationStation(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      type: type ?? this.type,
      availableSlots: availableSlots ?? this.availableSlots,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

/// Route information model
class RouteInfo {
  final List<LatLng> polylinePoints;
  final List<NavStep> navSteps;
  final double distanceKm;
  final int durationMinutes;

  RouteInfo({
    required this.polylinePoints,
    required this.navSteps,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

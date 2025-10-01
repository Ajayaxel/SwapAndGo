import 'package:google_maps_flutter/google_maps_flutter.dart';

// models/station_model.dart

/// Operating hours model for stations
class OperatingHours {
  final Map<String, DayHours> days;

  OperatingHours({required this.days});

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    final Map<String, DayHours> days = {};
    for (final entry in json.entries) {
      days[entry.key] = DayHours.fromJson(entry.value);
    }
    return OperatingHours(days: days);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    for (final entry in days.entries) {
      result[entry.key] = entry.value.toJson();
    }
    return result;
  }

  @override
  String toString() {
    return days.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }
}

class DayHours {
  final bool enabled;
  final String startTime;
  final String endTime;

  DayHours({
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      enabled: json['enabled'] ?? false,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  @override
  String toString() {
    return enabled ? '$startTime - $endTime' : 'Closed';
  }
}
class Station {
  final String id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String state;
  final String country;
  final String? postalCode;
  final String latitude;
  final String longitude;
  final String contactNumber;
  final String? email;
  final String? managerName;
  final int capacity;
  final int availableSlots;
  final bool is24x7;
  final OperatingHours? operatingHours;
  final String status;
  final bool isActive;
  final String? notes;
  final String? companyId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic company;

  Station({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    this.email,
    this.managerName,
    required this.capacity,
    required this.availableSlots,
    required this.is24x7,
    this.operatingHours,
    required this.status,
    required this.isActive,
    this.notes,
    this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.company,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'],
      latitude: json['latitude'] ?? '0.0',
      longitude: json['longitude'] ?? '0.0',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'],
      managerName: json['manager_name'],
      capacity: json['capacity'] ?? 0,
      availableSlots: json['available_slots'] ?? 0,
      is24x7: json['is_24_7'] ?? false,
      operatingHours: json['operating_hours'] != null 
          ? OperatingHours.fromJson(json['operating_hours']) 
          : null,
      status: json['status'] ?? '',
      isActive: json['is_active'] ?? false,
      notes: json['notes'],
      companyId: json['company_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      company: json['company'],
    );
  }

  /// Get position as LatLng for Google Maps
  LatLng get position => LatLng(
    double.tryParse(latitude) ?? 0.0,
    double.tryParse(longitude) ?? 0.0,
  );

  /// Get station type based on capacity
  String get type {
    if (capacity >= 200) return 'Fast Charge';
    if (capacity >= 100) return 'Standard';
    return 'Basic';
  }

  /// Check if station is available
  bool get isAvailable => isActive && availableSlots > 0;
}

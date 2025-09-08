// models/station_model.dart
class Station {
  final String id;
  final String name;
  final String address;
  final bool is24x7;
  final int capacity;
  final int availableSlots;

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.is24x7,
    required this.capacity,
    required this.availableSlots,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      is24x7: json['is_24_7'] ?? false,
      capacity: json['capacity'] ?? 0,
      availableSlots: json['available_slots'] ?? 0,
    );
  }
}

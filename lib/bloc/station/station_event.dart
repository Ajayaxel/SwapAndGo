// bloc/station_event.dart
abstract class StationEvent {}

class LoadStations extends StationEvent {
  final String? search;
  final String? status;
  final String? city;
  final String? is24x7;
  final String? isActive;
  final int perPage;

  LoadStations({
    this.search,
    this.status,
    this.city,
    this.is24x7,
    this.isActive,
    this.perPage = 15,
  });
}

class LoadStationById extends StationEvent {
  final String stationId;

  LoadStationById(this.stationId);
}

class RefreshStations extends StationEvent {
  final String? search;
  final String? status;
  final String? city;
  final String? is24x7;
  final String? isActive;
  final int perPage;

  RefreshStations({
    this.search,
    this.status,
    this.city,
    this.is24x7,
    this.isActive,
    this.perPage = 15,
  });
}

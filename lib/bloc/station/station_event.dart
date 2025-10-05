// bloc/station_event.dart
import 'package:swap_app/model/station_model.dart';

abstract class StationEvent {}

class LoadStations extends StationEvent {
  final String? search;
  final String? status;
  final String? city;
  final String? is24x7;
  final String? isActive;
  final int perPage;
  final Station? selectedStation;

  LoadStations({
    this.search,
    this.status,
    this.city,
    this.is24x7,
    this.isActive,
    this.perPage = 15,
    this.selectedStation,
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

class SelectStation extends StationEvent {
  final Station station;

  SelectStation(this.station,);
}

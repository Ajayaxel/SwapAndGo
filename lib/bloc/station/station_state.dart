// bloc/station_state.dart
import 'package:swap_app/model/station_model.dart';

abstract class StationState {}

class StationInitial extends StationState {}

class StationLoading extends StationState {}

class StationLoaded extends StationState {
  final List<Station> stations;
  StationLoaded(this.stations);
}

class StationRefreshing extends StationState {
  final List<Station> currentStations;
  StationRefreshing(this.currentStations);
}

class SingleStationLoaded extends StationState {
  final Station station;
  SingleStationLoaded(this.station);
}

class StationError extends StationState {
  final String message;
  final List<Station>? previousStations;
  StationError(this.message, [this.previousStations]);
}


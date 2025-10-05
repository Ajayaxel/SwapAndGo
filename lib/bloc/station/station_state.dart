// bloc/station_state.dart
import 'package:equatable/equatable.dart';
import 'package:swap_app/model/station_model.dart';

abstract class StationState extends Equatable{}

class StationInitial extends StationState {
  @override
  List<Object?> get props => [];
}

class StationLoading extends StationState {
  @override
  List<Object?> get props => [];
}

class StationLoaded extends StationState {  
  final List<Station> stations;
  final Station? selectedStation;
  StationLoaded(this.stations, this.selectedStation);
  @override
  List<Object?> get props => [stations, selectedStation];
}

class StationRefreshing extends StationState {
  final List<Station> currentStations;
  StationRefreshing(this.currentStations);
  @override
  List<Object?> get props => [currentStations];
}

class SingleStationLoaded extends StationState {
  final Station station;
  SingleStationLoaded(this.station);
  @override
  List<Object?> get props => [station];
}

class StationError extends StationState {
  final String message;
  final List<Station>? previousStations;
  StationError(this.message, [this.previousStations]);
  @override
  List<Object?> get props => [message, previousStations];
}


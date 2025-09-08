// bloc/station_state.dart


import 'package:swap_app/model/station_model.dart';

abstract class StationState {}

class StationInitial extends StationState {}

class StationLoading extends StationState {}

class StationLoaded extends StationState {
  final List<Station> stations;
  StationLoaded(this.stations);
}

class StationError extends StationState {
  final String message;
  StationError(this.message);
}


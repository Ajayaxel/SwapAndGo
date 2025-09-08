// bloc/station_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/repo/station_repository.dart';
import 'station_event.dart';
import 'station_state.dart';


class StationBloc extends Bloc<StationEvent, StationState> {
  final StationRepository repository;

  StationBloc(this.repository) : super(StationInitial()) {
    on<LoadStations>((event, emit) async {
      emit(StationLoading());
      try {
        final stations = await repository.fetchStations();
        emit(StationLoaded(stations));
      } catch (e) {
        emit(StationError(e.toString()));
      }
    });
  }
}


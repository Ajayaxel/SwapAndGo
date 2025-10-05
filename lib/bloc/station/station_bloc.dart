// bloc/station_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/repo/station_repository.dart';
import 'station_event.dart';
import 'station_state.dart';

class StationBloc extends Bloc<StationEvent, StationState> {
  final StationRepository repository;

  StationBloc(this.repository) : super(StationInitial()) {
    on<LoadStations>((event, emit) async {
      final selectedStation = event.selectedStation;
     
      emit(StationLoading());
      try {
        final stations = await repository.fetchStations(
          search: event.search,
          status: event.status,
          city: event.city,
          is24x7: event.is24x7,
          isActive: event.isActive,
          perPage: event.perPage,
        );
        emit(StationLoaded(stations, selectedStation, ));
      } on StationApiException catch (e) {
        print('❌ Station API Error: ${e.message}');
        emit(StationError(e.message));
      } catch (e) {
        print('❌ Unexpected error in LoadStations: $e');
        emit(StationError('An unexpected error occurred: ${e.toString()}'));
      }
    });

    on<SelectStation>((event, emit) async {
      if(state is StationLoaded) {
        emit(StationLoaded((state as StationLoaded).stations, event.station));
      } 
    });

    on<LoadStationById>((event, emit) async {
      emit(StationLoading());
      try {
        final station = await repository.fetchStationById(event.stationId);
        emit(SingleStationLoaded(station));
      } on StationApiException catch (e) {
        print('❌ Station API Error: ${e.message}');
        emit(StationError(e.message));
      } catch (e) {
        print('❌ Unexpected error in LoadStationById: $e');
        emit(StationError('An unexpected error occurred: ${e.toString()}'));
      }
    });

    on<RefreshStations>((event, emit) async {
      // Keep current stations while refreshing
      if (state is StationLoaded) {
        emit(StationRefreshing((state as StationLoaded).stations));
      } else {
        emit(StationLoading());
      }
      
      try {
        final stations = await repository.fetchStations(
          search: event.search,
          status: event.status,
          city: event.city,
          is24x7: event.is24x7,
          isActive: event.isActive,
          perPage: event.perPage,
        );
        emit(StationLoaded(stations, null));
      } on StationApiException catch (e) {
        print('❌ Station API Error during refresh: ${e.message}');
        // Keep previous stations on error
        if (state is StationRefreshing) {
          emit(StationError(e.message, (state as StationRefreshing).currentStations));
        } else {
          emit(StationError(e.message));
        }
      } catch (e) {
        print('❌ Unexpected error in RefreshStations: $e');
        // Keep previous stations on error
        if (state is StationRefreshing) {
          emit(StationError('An unexpected error occurred: ${e.toString()}', (state as StationRefreshing).currentStations));
        } else {
          emit(StationError('An unexpected error occurred: ${e.toString()}'));
        }
      }
    });
  }
}


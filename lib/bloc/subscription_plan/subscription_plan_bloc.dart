// bloc/subscription_plan/subscription_plan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/repo/subscription_plan_repository.dart';
import 'package:swap_app/services/subscription_plan_service.dart';
import 'subscription_plan_event.dart';
import 'subscription_plan_state.dart';

class SubscriptionPlanBloc extends Bloc<SubscriptionPlanEvent, SubscriptionPlanState> {
  final SubscriptionPlanRepository repository;

  SubscriptionPlanBloc(this.repository) : super(SubscriptionPlanInitial()) {
    on<LoadSubscriptionPlans>(_onLoadSubscriptionPlans);
    on<RefreshSubscriptionPlans>(_onRefreshSubscriptionPlans);
  }

  /// Load subscription plans
  Future<void> _onLoadSubscriptionPlans(
    LoadSubscriptionPlans event,
    Emitter<SubscriptionPlanState> emit,
  ) async {
    emit(SubscriptionPlanLoading());
    try {
      final response = await repository.fetchSubscriptionPlans();

      if (response.plans.isEmpty) {
        emit(SubscriptionPlanEmpty());
      } else {
        emit(SubscriptionPlanLoaded(
          plans: response.plans,
          count: response.count,
        ));
      }
    } on SubscriptionPlanException catch (e) {
      print('❌ Subscription Plan API Error: ${e.message}');
      emit(SubscriptionPlanError(e.message));
    } catch (e) {
      print('❌ Unexpected error in LoadSubscriptionPlans: $e');
      emit(SubscriptionPlanError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Refresh subscription plans
  Future<void> _onRefreshSubscriptionPlans(
    RefreshSubscriptionPlans event,
    Emitter<SubscriptionPlanState> emit,
  ) async {
    // Keep current plans while refreshing
    if (state is SubscriptionPlanLoaded) {
      emit(SubscriptionPlanRefreshing(
        (state as SubscriptionPlanLoaded).plans,
      ));
    } else {
      emit(SubscriptionPlanLoading());
    }

    try {
      final response = await repository.fetchSubscriptionPlans();

      if (response.plans.isEmpty) {
        emit(SubscriptionPlanEmpty());
      } else {
        emit(SubscriptionPlanLoaded(
          plans: response.plans,
          count: response.count,
        ));
      }
    } on SubscriptionPlanException catch (e) {
      print('❌ Subscription Plan API Error during refresh: ${e.message}');
      // Keep previous plans on error
      if (state is SubscriptionPlanRefreshing) {
        emit(SubscriptionPlanError(
          e.message,
          (state as SubscriptionPlanRefreshing).currentPlans,
        ));
      } else {
        emit(SubscriptionPlanError(e.message));
      }
    } catch (e) {
      print('❌ Unexpected error in RefreshSubscriptionPlans: $e');
      // Keep previous plans on error
      if (state is SubscriptionPlanRefreshing) {
        emit(SubscriptionPlanError(
          'An unexpected error occurred: ${e.toString()}',
          (state as SubscriptionPlanRefreshing).currentPlans,
        ));
      } else {
        emit(SubscriptionPlanError('An unexpected error occurred: ${e.toString()}'));
      }
    }
  }
}


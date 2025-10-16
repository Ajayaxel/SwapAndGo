// bloc/subscription_plan/subscription_plan_state.dart
import 'package:equatable/equatable.dart';
import 'package:swap_app/model/subscription_plan_model.dart';

abstract class SubscriptionPlanState extends Equatable {}

/// Initial state
class SubscriptionPlanInitial extends SubscriptionPlanState {
  @override
  List<Object?> get props => [];
}

/// Loading state
class SubscriptionPlanLoading extends SubscriptionPlanState {
  @override
  List<Object?> get props => [];
}

/// Loaded state
class SubscriptionPlanLoaded extends SubscriptionPlanState {
  final List<SubscriptionPlan> plans;
  final int count;

  SubscriptionPlanLoaded({
    required this.plans,
    required this.count,
  });

  @override
  List<Object?> get props => [plans, count];
}

/// Refreshing state (keep current data while refreshing)
class SubscriptionPlanRefreshing extends SubscriptionPlanState {
  final List<SubscriptionPlan> currentPlans;

  SubscriptionPlanRefreshing(this.currentPlans);

  @override
  List<Object?> get props => [currentPlans];
}

/// Error state
class SubscriptionPlanError extends SubscriptionPlanState {
  final String message;
  final List<SubscriptionPlan>? previousPlans;

  SubscriptionPlanError(this.message, [this.previousPlans]);

  @override
  List<Object?> get props => [message, previousPlans];
}

/// Empty state (no plans available)
class SubscriptionPlanEmpty extends SubscriptionPlanState {
  @override
  List<Object?> get props => [];
}


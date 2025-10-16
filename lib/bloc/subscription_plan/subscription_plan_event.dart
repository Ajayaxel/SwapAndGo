// bloc/subscription_plan/subscription_plan_event.dart

abstract class SubscriptionPlanEvent {}

/// Load subscription plans
class LoadSubscriptionPlans extends SubscriptionPlanEvent {}

/// Refresh subscription plans
class RefreshSubscriptionPlans extends SubscriptionPlanEvent {}


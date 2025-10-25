// bloc/active_subscription/active_subscription_state.dart
import 'package:swap_app/model/active_subscription_models.dart';

/// Base class for active subscription states
abstract class ActiveSubscriptionState {}

/// Initial state
class ActiveSubscriptionInitial extends ActiveSubscriptionState {}

/// Loading state
class ActiveSubscriptionLoading extends ActiveSubscriptionState {}

/// Loaded state with subscription data
class ActiveSubscriptionLoaded extends ActiveSubscriptionState {
  final ActiveSubscriptionResponse response;
  final ActiveSubscriptionData subscription;
  final SubscriptionPlan plan;
  final List<SubscriptionTransaction> transactions;

  ActiveSubscriptionLoaded({
    required this.response,
    required this.subscription,
    required this.plan,
    required this.transactions,
  });
}

/// Empty state (no active subscription found)
class ActiveSubscriptionEmpty extends ActiveSubscriptionState {
  final String message;

  ActiveSubscriptionEmpty({required this.message});
}

/// Error state
class ActiveSubscriptionError extends ActiveSubscriptionState {
  final String message;
  final int? statusCode;

  ActiveSubscriptionError({
    required this.message,
    this.statusCode,
  });
}

/// Network error state
class ActiveSubscriptionNetworkError extends ActiveSubscriptionState {
  final String message;

  ActiveSubscriptionNetworkError({required this.message});
}

/// Cancelling subscription state
class ActiveSubscriptionCancelling extends ActiveSubscriptionState {}

/// Subscription cancelled state
class ActiveSubscriptionCancelled extends ActiveSubscriptionState {
  final String message;

  ActiveSubscriptionCancelled({required this.message});
}

/// Updating payment method state
class ActiveSubscriptionUpdatingPayment extends ActiveSubscriptionState {}

/// Payment method updated state
class ActiveSubscriptionPaymentUpdated extends ActiveSubscriptionState {
  final String message;

  ActiveSubscriptionPaymentUpdated({required this.message});
}

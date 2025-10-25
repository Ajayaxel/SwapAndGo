// bloc/active_subscription/active_subscription_event.dart

/// Base class for active subscription events
abstract class ActiveSubscriptionEvent {}

/// Event to fetch active subscription details
class FetchActiveSubscription extends ActiveSubscriptionEvent {}

/// Event to refresh active subscription details
class RefreshActiveSubscription extends ActiveSubscriptionEvent {}

/// Event to cancel active subscription
class CancelActiveSubscription extends ActiveSubscriptionEvent {
  final String? reason;

  CancelActiveSubscription({this.reason});
}

/// Event to update payment method
class UpdatePaymentMethod extends ActiveSubscriptionEvent {
  final String cardToken;
  final String? cardLastFour;
  final String? cardBrand;

  UpdatePaymentMethod({
    required this.cardToken,
    this.cardLastFour,
    this.cardBrand,
  });
}

/// Event to reset active subscription state
class ResetActiveSubscriptionState extends ActiveSubscriptionEvent {}

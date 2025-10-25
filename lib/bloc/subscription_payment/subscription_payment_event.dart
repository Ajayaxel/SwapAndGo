// bloc/subscription_payment/subscription_payment_event.dart

abstract class SubscriptionPaymentEvent {}

/// Initialize payment for a subscription plan
class InitializePayment extends SubscriptionPaymentEvent {
  final int planId;

  InitializePayment({required this.planId});
}

/// Check payment status
class CheckPaymentStatus extends SubscriptionPaymentEvent {
  final String subscriptionId;

  CheckPaymentStatus({required this.subscriptionId});
}

/// Payment completed successfully
class PaymentCompleted extends SubscriptionPaymentEvent {
  final String subscriptionId;
  final String message;

  PaymentCompleted({
    required this.subscriptionId,
    required this.message,
  });
}

/// Payment failed
class PaymentFailed extends SubscriptionPaymentEvent {
  final String message;

  PaymentFailed({required this.message});
}

/// Reset payment state
class ResetPaymentState extends SubscriptionPaymentEvent {}

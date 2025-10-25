// bloc/subscription_payment/subscription_payment_state.dart
import 'package:equatable/equatable.dart';
import 'package:swap_app/model/payment_models.dart';

abstract class SubscriptionPaymentState extends Equatable {}

/// Initial state
class SubscriptionPaymentInitial extends SubscriptionPaymentState {
  @override
  List<Object?> get props => [];
}

/// Loading state - initializing payment
class PaymentInitializing extends SubscriptionPaymentState {
  @override
  List<Object?> get props => [];
}

/// Payment initialized successfully
class PaymentInitialized extends SubscriptionPaymentState {
  final PaymentInitializationResponse paymentResponse;

  PaymentInitialized({required this.paymentResponse});

  @override
  List<Object?> get props => [paymentResponse];
}

/// Checking payment status
class CheckingPaymentStatus extends SubscriptionPaymentState {
  @override
  List<Object?> get props => [];
}

/// Payment completed successfully
class PaymentSuccess extends SubscriptionPaymentState {
  final String subscriptionId;
  final String message;

  PaymentSuccess({
    required this.subscriptionId,
    required this.message,
  });

  @override
  List<Object?> get props => [subscriptionId, message];
}

/// Payment failed
class PaymentFailure extends SubscriptionPaymentState {
  final String message;

  PaymentFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Payment error
class PaymentError extends SubscriptionPaymentState {
  final String message;

  PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}

// bloc/subscription_transaction_api/subscription_transaction_api_state.dart
import 'package:swap_app/model/subscription_transaction_models.dart';

/// Base class for subscription transaction API states
abstract class SubscriptionTransactionApiState {}

/// Initial state
class SubscriptionTransactionApiInitial extends SubscriptionTransactionApiState {}

/// Loading state
class SubscriptionTransactionApiLoading extends SubscriptionTransactionApiState {}

/// Loaded state with transaction data
class SubscriptionTransactionApiLoaded extends SubscriptionTransactionApiState {
  final SubscriptionTransactionResponse response;
  final List<SubscriptionTransaction> transactions;
  final int count;
  final int totalPaid;

  SubscriptionTransactionApiLoaded({
    required this.response,
    required this.transactions,
    required this.count,
    required this.totalPaid,
  });
}

/// Empty state (no transactions found)
class SubscriptionTransactionApiEmpty extends SubscriptionTransactionApiState {
  final String message;

  SubscriptionTransactionApiEmpty({required this.message});
}

/// Error state
class SubscriptionTransactionApiError extends SubscriptionTransactionApiState {
  final String message;
  final int? statusCode;

  SubscriptionTransactionApiError({
    required this.message,
    this.statusCode,
  });
}

/// Network error state
class SubscriptionTransactionApiNetworkError extends SubscriptionTransactionApiState {
  final String message;

  SubscriptionTransactionApiNetworkError({required this.message});
}

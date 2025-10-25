// bloc/subscription_transaction_api/subscription_transaction_api_event.dart

/// Base class for subscription transaction API events
abstract class SubscriptionTransactionApiEvent {}

/// Event to fetch subscription transactions using new API structure
class FetchSubscriptionTransactionsApi extends SubscriptionTransactionApiEvent {}

/// Event to refresh subscription transactions
class RefreshSubscriptionTransactionsApi extends SubscriptionTransactionApiEvent {}

/// Event to reset subscription transaction state
class ResetSubscriptionTransactionApiState extends SubscriptionTransactionApiEvent {}

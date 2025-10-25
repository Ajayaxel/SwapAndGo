// bloc/subscription_transaction_api/subscription_transaction_api_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/services/subscription_transaction_service.dart';
import 'package:swap_app/model/subscription_transaction_models.dart';
import 'subscription_transaction_api_event.dart';
import 'subscription_transaction_api_state.dart';

class SubscriptionTransactionApiBloc extends Bloc<SubscriptionTransactionApiEvent, SubscriptionTransactionApiState> {
  final SubscriptionTransactionService _transactionService = SubscriptionTransactionService();

  SubscriptionTransactionApiBloc() : super(SubscriptionTransactionApiInitial()) {
    on<FetchSubscriptionTransactionsApi>(_onFetchSubscriptionTransactionsApi);
    on<RefreshSubscriptionTransactionsApi>(_onRefreshSubscriptionTransactionsApi);
    on<ResetSubscriptionTransactionApiState>(_onResetSubscriptionTransactionApiState);
  }

  /// Fetch subscription transactions with new API structure
  Future<void> _onFetchSubscriptionTransactionsApi(
    FetchSubscriptionTransactionsApi event,
    Emitter<SubscriptionTransactionApiState> emit,
  ) async {
    emit(SubscriptionTransactionApiLoading());
    try {
      final response = await _transactionService.getSubscriptionTransactions();

      if (response.success) {
        if (response.data != null && response.data!.transactions.isNotEmpty) {
          emit(SubscriptionTransactionApiLoaded(
            response: response,
            transactions: response.data!.transactions,
            count: response.data!.count,
            totalPaid: response.data!.totalPaid,
          ));
        } else {
          emit(SubscriptionTransactionApiEmpty(message: response.message));
        }
      } else {
        emit(SubscriptionTransactionApiError(
          message: response.message,
          statusCode: 400,
        ));
      }
    } on SubscriptionTransactionException catch (e) {
      print('❌ Subscription Transaction API Error: ${e.message}');
      
      if (e.statusCode == 401) {
        emit(SubscriptionTransactionApiError(
          message: "Authentication failed. Please login again.",
          statusCode: e.statusCode,
        ));
      } else if (e.statusCode == 404) {
        emit(SubscriptionTransactionApiEmpty(message: e.message));
      } else if (e.statusCode == 0) {
        emit(SubscriptionTransactionApiNetworkError(message: e.message));
      } else {
        emit(SubscriptionTransactionApiError(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } catch (e) {
      print('❌ Unexpected error in FetchSubscriptionTransactionsApi: $e');
      emit(SubscriptionTransactionApiError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Refresh subscription transactions
  Future<void> _onRefreshSubscriptionTransactionsApi(
    RefreshSubscriptionTransactionsApi event,
    Emitter<SubscriptionTransactionApiState> emit,
  ) async {
    // Reset to loading state and fetch again
    add(FetchSubscriptionTransactionsApi());
  }

  /// Reset subscription transaction state
  void _onResetSubscriptionTransactionApiState(
    ResetSubscriptionTransactionApiState event,
    Emitter<SubscriptionTransactionApiState> emit,
  ) {
    emit(SubscriptionTransactionApiInitial());
  }
}

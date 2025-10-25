// bloc/active_subscription/active_subscription_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/active_subscription/active_subscription_event.dart';
import 'package:swap_app/bloc/active_subscription/active_subscription_state.dart';
import 'package:swap_app/model/active_subscription_models.dart';
import 'package:swap_app/services/active_subscription_service.dart';

class ActiveSubscriptionBloc extends Bloc<ActiveSubscriptionEvent, ActiveSubscriptionState> {
  final ActiveSubscriptionService _activeSubscriptionService;

  ActiveSubscriptionBloc({
    required ActiveSubscriptionService activeSubscriptionService,
  }) : _activeSubscriptionService = activeSubscriptionService,
       super(ActiveSubscriptionInitial()) {
    
    on<FetchActiveSubscription>(_onFetchActiveSubscription);
    on<RefreshActiveSubscription>(_onRefreshActiveSubscription);
    on<CancelActiveSubscription>(_onCancelActiveSubscription);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<ResetActiveSubscriptionState>(_onResetActiveSubscriptionState);
  }

  /// Fetch active subscription details
  Future<void> _onFetchActiveSubscription(
    FetchActiveSubscription event,
    Emitter<ActiveSubscriptionState> emit,
  ) async {
    try {
      emit(ActiveSubscriptionLoading());
      
      print('🔄 Fetching active subscription details...');
      
      final response = await _activeSubscriptionService.getActiveSubscription();
      
      if (response.success && response.data != null) {
        final subscription = response.data!;
        final plan = subscription.plan;
        final transactions = subscription.transactions;
        
        print('✅ Active subscription loaded successfully');
        print('📊 Subscription ID: ${subscription.id}');
        print('📊 Plan: ${plan.name}');
        print('📊 Status: ${subscription.status}');
        print('📊 Transactions: ${transactions.length}');
        
        emit(ActiveSubscriptionLoaded(
          response: response,
          subscription: subscription,
          plan: plan,
          transactions: transactions,
        ));
      } else {
        print('❌ No active subscription found');
        emit(ActiveSubscriptionEmpty(
          message: response.message.isNotEmpty 
              ? response.message 
              : "No active subscription found",
        ));
      }
    } on ActiveSubscriptionException catch (e) {
      print('❌ Active subscription error: ${e.message}');
      
      if (e.statusCode == 0) {
        emit(ActiveSubscriptionNetworkError(message: e.message));
      } else {
        emit(ActiveSubscriptionError(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(ActiveSubscriptionError(
        message: "An unexpected error occurred: ${e.toString()}",
      ));
    }
  }

  /// Refresh active subscription details
  Future<void> _onRefreshActiveSubscription(
    RefreshActiveSubscription event,
    Emitter<ActiveSubscriptionState> emit,
  ) async {
    try {
      print('🔄 Refreshing active subscription details...');
      
      final response = await _activeSubscriptionService.getActiveSubscription();
      
      if (response.success && response.data != null) {
        final subscription = response.data!;
        final plan = subscription.plan;
        final transactions = subscription.transactions;
        
        print('✅ Active subscription refreshed successfully');
        
        emit(ActiveSubscriptionLoaded(
          response: response,
          subscription: subscription,
          plan: plan,
          transactions: transactions,
        ));
      } else {
        print('❌ No active subscription found on refresh');
        emit(ActiveSubscriptionEmpty(
          message: response.message.isNotEmpty 
              ? response.message 
              : "No active subscription found",
        ));
      }
    } on ActiveSubscriptionException catch (e) {
      print('❌ Active subscription refresh error: ${e.message}');
      
      if (e.statusCode == 0) {
        emit(ActiveSubscriptionNetworkError(message: e.message));
      } else {
        emit(ActiveSubscriptionError(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } catch (e) {
      print('❌ Unexpected refresh error: $e');
      emit(ActiveSubscriptionError(
        message: "An unexpected error occurred: ${e.toString()}",
      ));
    }
  }

  /// Cancel active subscription
  Future<void> _onCancelActiveSubscription(
    CancelActiveSubscription event,
    Emitter<ActiveSubscriptionState> emit,
  ) async {
    try {
      emit(ActiveSubscriptionCancelling());
      
      print('🔄 Cancelling active subscription...');
      
      final response = await _activeSubscriptionService.cancelSubscription(
        reason: event.reason,
      );
      
      if (response.success) {
        print('✅ Subscription cancelled successfully');
        emit(ActiveSubscriptionCancelled(
          message: response.message.isNotEmpty 
              ? response.message 
              : "Subscription cancelled successfully",
        ));
      } else {
        print('❌ Failed to cancel subscription');
        emit(ActiveSubscriptionError(
          message: response.message.isNotEmpty 
              ? response.message 
              : "Failed to cancel subscription",
        ));
      }
    } on ActiveSubscriptionException catch (e) {
      print('❌ Cancel subscription error: ${e.message}');
      
      if (e.statusCode == 0) {
        emit(ActiveSubscriptionNetworkError(message: e.message));
      } else {
        emit(ActiveSubscriptionError(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } catch (e) {
      print('❌ Unexpected cancel error: $e');
      emit(ActiveSubscriptionError(
        message: "An unexpected error occurred: ${e.toString()}",
      ));
    }
  }

  /// Update payment method
  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<ActiveSubscriptionState> emit,
  ) async {
    try {
      emit(ActiveSubscriptionUpdatingPayment());
      
      print('🔄 Updating payment method...');
      
      final response = await _activeSubscriptionService.updatePaymentMethod(
        cardToken: event.cardToken,
        cardLastFour: event.cardLastFour,
        cardBrand: event.cardBrand,
      );
      
      if (response.success) {
        print('✅ Payment method updated successfully');
        emit(ActiveSubscriptionPaymentUpdated(
          message: response.message.isNotEmpty 
              ? response.message 
              : "Payment method updated successfully",
        ));
        
        // Refresh subscription details after successful update
        add(RefreshActiveSubscription());
      } else {
        print('❌ Failed to update payment method');
        emit(ActiveSubscriptionError(
          message: response.message.isNotEmpty 
              ? response.message 
              : "Failed to update payment method",
        ));
      }
    } on ActiveSubscriptionException catch (e) {
      print('❌ Update payment method error: ${e.message}');
      
      if (e.statusCode == 0) {
        emit(ActiveSubscriptionNetworkError(message: e.message));
      } else {
        emit(ActiveSubscriptionError(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } catch (e) {
      print('❌ Unexpected update payment error: $e');
      emit(ActiveSubscriptionError(
        message: "An unexpected error occurred: ${e.toString()}",
      ));
    }
  }

  /// Reset active subscription state
  void _onResetActiveSubscriptionState(
    ResetActiveSubscriptionState event,
    Emitter<ActiveSubscriptionState> emit,
  ) {
    print('🔄 Resetting active subscription state');
    emit(ActiveSubscriptionInitial());
  }
}

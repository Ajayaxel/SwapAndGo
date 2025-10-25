// bloc/subscription_payment/subscription_payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/services/subscription_payment_service.dart';
import 'subscription_payment_event.dart';
import 'subscription_payment_state.dart';

class SubscriptionPaymentBloc extends Bloc<SubscriptionPaymentEvent, SubscriptionPaymentState> {
  final SubscriptionPaymentService _paymentService = SubscriptionPaymentService();

  SubscriptionPaymentBloc() : super(SubscriptionPaymentInitial()) {
    on<InitializePayment>(_onInitializePayment);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
    on<PaymentCompleted>(_onPaymentCompleted);
    on<PaymentFailed>(_onPaymentFailed);
    on<ResetPaymentState>(_onResetPaymentState);
  }

  /// Initialize payment for a subscription plan
  Future<void> _onInitializePayment(
    InitializePayment event,
    Emitter<SubscriptionPaymentState> emit,
  ) async {
    emit(PaymentInitializing());
    try {
      final response = await _paymentService.initializePayment(
        planId: event.planId,
      );

      emit(PaymentInitialized(paymentResponse: response));
    } on SubscriptionPaymentException catch (e) {
      print('❌ Payment Initialization Error: ${e.message}');
      emit(PaymentError(message: e.message));
    } catch (e) {
      print('❌ Unexpected error in InitializePayment: $e');
      emit(PaymentError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Check payment status
  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatus event,
    Emitter<SubscriptionPaymentState> emit,
  ) async {
    emit(CheckingPaymentStatus());
    try {
      final response = await _paymentService.checkPaymentStatus(
        subscriptionId: event.subscriptionId,
      );

      if (response.success) {
        emit(PaymentSuccess(
          subscriptionId: event.subscriptionId,
          message: response.message,
        ));
      } else {
        emit(PaymentFailure(message: response.message));
      }
    } on SubscriptionPaymentException catch (e) {
      print('❌ Payment Status Check Error: ${e.message}');
      emit(PaymentError(message: e.message));
    } catch (e) {
      print('❌ Unexpected error in CheckPaymentStatus: $e');
      emit(PaymentError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handle payment completed
  void _onPaymentCompleted(
    PaymentCompleted event,
    Emitter<SubscriptionPaymentState> emit,
  ) {
    emit(PaymentSuccess(
      subscriptionId: event.subscriptionId,
      message: event.message,
    ));
  }

  /// Handle payment failed
  void _onPaymentFailed(
    PaymentFailed event,
    Emitter<SubscriptionPaymentState> emit,
  ) {
    emit(PaymentFailure(message: event.message));
  }

  /// Reset payment state
  void _onResetPaymentState(
    ResetPaymentState event,
    Emitter<SubscriptionPaymentState> emit,
  ) {
    emit(SubscriptionPaymentInitial());
  }
}

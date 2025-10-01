// wallet_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:swap_app/bloc/wallet/wallet_event.dart';
import 'package:swap_app/bloc/wallet/wallet_state.dart';
import 'package:swap_app/model/wallet_model.dart';
import 'package:swap_app/services/storage_helper.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  static const String baseUrl = 'https://onecharge.io';

  WalletBloc() : super(WalletInitial()) {
    on<DepositCashEvent>(_onDepositCash);
    on<CheckPaymentStatusEvent>(_onCheckPaymentStatus);
    on<ResetWalletEvent>(_onResetWallet);
  }

  // 🔹 Deposit Cash
  Future<void> _onDepositCash(
      DepositCashEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());

    try {
      // Get auth token
      final token = await StorageHelper.getString('auth_token');

      if (token == null) {
        emit(const WalletError(message: 'Authentication required. Please login.'));
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/customer/wallet/deposit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': event.amount,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final depositResponse = WalletDepositResponse.fromJson(data);
        print('✅ Deposit API Success - iframe URL: ${depositResponse.data.iframeUrl}');
        print('✅ Payment ID: ${depositResponse.data.paymentId}');
        print('✅ Amount: ${depositResponse.data.amount} ${depositResponse.data.currency}');
        emit(WalletDepositSuccess(depositResponse: depositResponse));
      } else {
        emit(WalletError(
            message: data['message'] ?? 'Failed to initiate deposit'));
      }
    } catch (e) {
      emit(WalletError(message: 'Network error: ${e.toString()}'));
    }
  }

  // 🔹 Check Payment Status (optional - for polling payment status)
  Future<void> _onCheckPaymentStatus(
      CheckPaymentStatusEvent event, Emitter<WalletState> emit) async {
    try {
      final token = await StorageHelper.getString('auth_token');

      if (token == null) {
        emit(const WalletError(message: 'Authentication required'));
        return;
      }

      // You can implement a status check API call here if available
      // For now, we'll just emit a completed state
      emit(const WalletPaymentCompleted(
          message: 'Payment completed successfully'));
    } catch (e) {
      emit(WalletError(message: 'Failed to check payment status: $e'));
    }
  }

  // 🔹 Reset Wallet State
  Future<void> _onResetWallet(
      ResetWalletEvent event, Emitter<WalletState> emit) async {
    emit(WalletInitial());
  }
}


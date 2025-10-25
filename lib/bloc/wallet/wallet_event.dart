// wallet_event.dart
import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class DepositCashEvent extends WalletEvent {
  final double amount;

  const DepositCashEvent({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class CheckPaymentStatusEvent extends WalletEvent {
  final String paymentId;

  const CheckPaymentStatusEvent({required this.paymentId});

  @override
  List<Object?> get props => [paymentId];
}

class ResetWalletEvent extends WalletEvent {
  const ResetWalletEvent();
}

class FetchWalletBalanceEvent extends WalletEvent {
  const FetchWalletBalanceEvent();
}
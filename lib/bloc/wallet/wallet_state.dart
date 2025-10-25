// wallet_state.dart
import 'package:equatable/equatable.dart';
import 'package:swap_app/model/wallet_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletDepositSuccess extends WalletState {
  final WalletDepositResponse depositResponse;

  const WalletDepositSuccess({required this.depositResponse});

  @override
  List<Object?> get props => [depositResponse];
}

class WalletPaymentCompleted extends WalletState {
  final String message;

  const WalletPaymentCompleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class WalletBalanceLoaded extends WalletState {
  final WalletBalanceResponse balanceResponse;

  const WalletBalanceLoaded({required this.balanceResponse});

  @override
  List<Object?> get props => [balanceResponse];
}

class WalletError extends WalletState {
  final String message;
  final int ?statusCode;
  const WalletError({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

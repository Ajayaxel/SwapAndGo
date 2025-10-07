// bloc/swap_history/swap_history_state.dart
import 'package:equatable/equatable.dart';
import 'package:swap_app/model/swap_history_model.dart';

abstract class SwapHistoryState extends Equatable {}

/// Initial state
class SwapHistoryInitial extends SwapHistoryState {
  @override
  List<Object?> get props => [];
}

/// Loading state
class SwapHistoryLoading extends SwapHistoryState {
  @override
  List<Object?> get props => [];
}

/// Loaded state
class SwapHistoryLoaded extends SwapHistoryState {
  final List<SwapTransaction> transactions;
  final Pagination pagination;

  SwapHistoryLoaded({
    required this.transactions,
    required this.pagination,
  });

  @override
  List<Object?> get props => [transactions, pagination];
}

/// Refreshing state (keep current data while refreshing)
class SwapHistoryRefreshing extends SwapHistoryState {
  final List<SwapTransaction> currentTransactions;

  SwapHistoryRefreshing(this.currentTransactions);

  @override
  List<Object?> get props => [currentTransactions];
}

/// Loading more state (pagination)
class SwapHistoryLoadingMore extends SwapHistoryState {
  final List<SwapTransaction> currentTransactions;
  final Pagination pagination;

  SwapHistoryLoadingMore({
    required this.currentTransactions,
    required this.pagination,
  });

  @override
  List<Object?> get props => [currentTransactions, pagination];
}

/// Error state
class SwapHistoryError extends SwapHistoryState {
  final String message;
  final List<SwapTransaction>? previousTransactions;

  SwapHistoryError(this.message, [this.previousTransactions]);

  @override
  List<Object?> get props => [message, previousTransactions];
}

/// Empty state (no transactions)
class SwapHistoryEmpty extends SwapHistoryState {
  @override
  List<Object?> get props => [];
}


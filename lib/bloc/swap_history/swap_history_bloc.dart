// bloc/swap_history/swap_history_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/repo/swap_history_repository.dart';
import 'package:swap_app/services/swap_history_service.dart';
import 'swap_history_event.dart';
import 'swap_history_state.dart';

class SwapHistoryBloc extends Bloc<SwapHistoryEvent, SwapHistoryState> {
  final SwapHistoryRepository repository;

  SwapHistoryBloc(this.repository) : super(SwapHistoryInitial()) {
    on<LoadSwapHistory>(_onLoadSwapHistory);
    on<RefreshSwapHistory>(_onRefreshSwapHistory);
    on<LoadMoreSwapHistory>(_onLoadMoreSwapHistory);
  }

  /// Load swap history
  Future<void> _onLoadSwapHistory(
    LoadSwapHistory event,
    Emitter<SwapHistoryState> emit,
  ) async {
    emit(SwapHistoryLoading());
    try {
      final response = await repository.fetchSwapHistory(
        limit: event.limit,
        page: event.page,
      );

      if (response.data.isEmpty) {
        emit(SwapHistoryEmpty());
      } else {
        emit(SwapHistoryLoaded(
          transactions: response.data,
          pagination: response.pagination,
        ));
      }
    } on SwapHistoryException catch (e) {
      print('❌ Swap History API Error: ${e.message}');
      emit(SwapHistoryError(e.message));
    } catch (e) {
      print('❌ Unexpected error in LoadSwapHistory: $e');
      emit(SwapHistoryError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Refresh swap history
  Future<void> _onRefreshSwapHistory(
    RefreshSwapHistory event,
    Emitter<SwapHistoryState> emit,
  ) async {
    // Keep current transactions while refreshing
    if (state is SwapHistoryLoaded) {
      emit(SwapHistoryRefreshing(
        (state as SwapHistoryLoaded).transactions,
      ));
    } else {
      emit(SwapHistoryLoading());
    }

    try {
      final response = await repository.fetchSwapHistory(
        limit: event.limit,
        page: 1,
      );

      if (response.data.isEmpty) {
        emit(SwapHistoryEmpty());
      } else {
        emit(SwapHistoryLoaded(
          transactions: response.data,
          pagination: response.pagination,
        ));
      }
    } on SwapHistoryException catch (e) {
      print('❌ Swap History API Error during refresh: ${e.message}');
      // Keep previous transactions on error
      if (state is SwapHistoryRefreshing) {
        emit(SwapHistoryError(
          e.message,
          (state as SwapHistoryRefreshing).currentTransactions,
        ));
      } else {
        emit(SwapHistoryError(e.message));
      }
    } catch (e) {
      print('❌ Unexpected error in RefreshSwapHistory: $e');
      // Keep previous transactions on error
      if (state is SwapHistoryRefreshing) {
        emit(SwapHistoryError(
          'An unexpected error occurred: ${e.toString()}',
          (state as SwapHistoryRefreshing).currentTransactions,
        ));
      } else {
        emit(SwapHistoryError('An unexpected error occurred: ${e.toString()}'));
      }
    }
  }

  /// Load more swap history (pagination)
  Future<void> _onLoadMoreSwapHistory(
    LoadMoreSwapHistory event,
    Emitter<SwapHistoryState> emit,
  ) async {
    if (state is SwapHistoryLoaded) {
      final currentState = state as SwapHistoryLoaded;
      
      // Check if there are more pages
      if (!currentState.pagination.hasNextPage) {
        print('📄 No more pages to load');
        return;
      }

      emit(SwapHistoryLoadingMore(
        currentTransactions: currentState.transactions,
        pagination: currentState.pagination,
      ));

      try {
        final response = await repository.fetchSwapHistory(
          limit: event.limit,
          page: currentState.pagination.currentPage + 1,
        );

        // Combine old and new transactions
        final allTransactions = [
          ...currentState.transactions,
          ...response.data,
        ];

        emit(SwapHistoryLoaded(
          transactions: allTransactions,
          pagination: response.pagination,
        ));
      } on SwapHistoryException catch (e) {
        print('❌ Swap History API Error during load more: ${e.message}');
        // Keep previous transactions on error
        emit(SwapHistoryError(e.message, currentState.transactions));
      } catch (e) {
        print('❌ Unexpected error in LoadMoreSwapHistory: $e');
        emit(SwapHistoryError(
          'An unexpected error occurred: ${e.toString()}',
          currentState.transactions,
        ));
      }
    }
  }
}


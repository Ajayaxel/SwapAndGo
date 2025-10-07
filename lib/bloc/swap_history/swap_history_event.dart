// bloc/swap_history/swap_history_event.dart

abstract class SwapHistoryEvent {}

/// Load swap history
class LoadSwapHistory extends SwapHistoryEvent {
  final int limit;
  final int page;

  LoadSwapHistory({
    this.limit = 20,
    this.page = 1,
  });
}

/// Refresh swap history
class RefreshSwapHistory extends SwapHistoryEvent {
  final int limit;

  RefreshSwapHistory({
    this.limit = 20,
  });
}

/// Load more swap history (pagination)
class LoadMoreSwapHistory extends SwapHistoryEvent {
  final int limit;

  LoadMoreSwapHistory({
    this.limit = 20,
  });
}


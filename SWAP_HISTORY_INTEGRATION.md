# Swap History Integration

## Overview
Complete BLoC pattern implementation for swap history feature with error handling, pagination, and pull-to-refresh support.

## API Endpoint
- **URL**: `https://onecharge.io/api/customer/swap/history`
- **Query Parameters**: 
  - `limit` (default: 20) - Number of records per page
  - `page` (default: 1) - Current page number
- **Authentication**: Required (Bearer token)

## Architecture

### 1. Model Layer (`lib/model/swap_history_model.dart`)
- **Battery**: Battery information with charge status
- **SwapStation**: Station details (simplified)
- **SwapTransaction**: Main transaction model with all swap details
- **Pagination**: Pagination information for API responses
- **SwapHistoryResponse**: Complete API response wrapper

### 2. Service Layer (`lib/services/swap_history_service.dart`)
- **SwapHistoryService**: Handles HTTP requests to the API
- **SwapHistoryException**: Custom exception for error handling
- Features:
  - Token-based authentication
  - Timeout handling (60 seconds)
  - Network connectivity checks
  - Comprehensive error messages

### 3. Repository Layer (`lib/repo/swap_history_repository.dart`)
- **SwapHistoryRepository**: Business logic and retry mechanisms
- Features:
  - Auto-retry logic (up to 3 attempts)
  - Network error handling
  - Exponential backoff for retries

### 4. BLoC Layer (`lib/bloc/swap_history/`)

#### Events (`swap_history_event.dart`)
- `LoadSwapHistory`: Initial data load
- `RefreshSwapHistory`: Pull-to-refresh
- `LoadMoreSwapHistory`: Load next page (pagination)

#### States (`swap_history_state.dart`)
- `SwapHistoryInitial`: Initial state
- `SwapHistoryLoading`: Loading state
- `SwapHistoryLoaded`: Data loaded successfully
- `SwapHistoryRefreshing`: Refreshing while keeping current data
- `SwapHistoryLoadingMore`: Loading more data (pagination)
- `SwapHistoryError`: Error state with optional previous data
- `SwapHistoryEmpty`: No transactions available

#### Bloc (`swap_history_bloc.dart`)
- Manages all state transitions
- Handles error cases gracefully
- Maintains data during refresh operations

### 5. UI Layer (`lib/presentation/account/history_screen.dart`)

#### Features
- ✅ Pull-to-refresh support
- ✅ Pagination with "Load More" button
- ✅ Loading states with circular progress indicators
- ✅ Empty state with helpful message
- ✅ Error state with retry button
- ✅ Beautiful transaction cards with:
  - Transaction date and time
  - Transaction type (Checkout/In Progress)
  - Battery code and charge information
  - Time since transaction
  - Station information (if available)
  - Transaction notes (if available)

## Usage

The screen automatically loads swap history when opened:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const HistoryScreen(),
  ),
);
```

## Error Handling

The implementation handles all error scenarios:
- ❌ Network errors (no internet)
- ❌ Authentication errors (401)
- ❌ Permission errors (403)
- ❌ Server errors (5xx)
- ❌ Timeout errors
- ❌ Invalid response format
- ❌ Empty data

Each error shows a user-friendly message with a retry button.

## UI States

1. **Loading**: Circular progress indicator
2. **Empty**: "No swap history yet" message with icon
3. **Error**: Error message with retry button
4. **Loaded**: List of transaction cards with pull-to-refresh
5. **Refreshing**: Shows current data while fetching new data
6. **Loading More**: Shows current data with loading indicator at bottom

## Dependencies Added
- `intl: ^0.19.0` - For date/time formatting

## Clean Code Principles
✅ Separation of concerns (Model, Service, Repository, BLoC, UI)
✅ Single Responsibility Principle
✅ Error handling at all layers
✅ Retry logic for network issues
✅ User-friendly error messages
✅ No hardcoded strings in critical logic
✅ Follows existing project patterns

## Testing Checklist
- [ ] Load history with data
- [ ] Load history with no data (empty state)
- [ ] Pull to refresh
- [ ] Load more (pagination)
- [ ] Error handling (no internet)
- [ ] Error handling (authentication failed)
- [ ] Retry after error
- [ ] Transaction card display
- [ ] Date/time formatting


# Wallet Cash Deposit Integration

## Overview
This integration implements a cash deposit feature using the OneCharge API with an iframe-based payment flow.

## API Details
- **Base URL**: `https://onecharge.io`
- **Endpoint**: `/api/customer/wallet/deposit`
- **Method**: `POST`
- **Authorization**: Bearer Token (from auth_token stored in SharedPreferences)

### Request Body
```json
{
    "amount": 10.00
}
```

### Response
```json
{
    "success": true,
    "data": {
        "payment_id": "PAY-TYVRDCSUHMFA",
        "order_id": 3083965,
        "payment_token": "...",
        "iframe_url": "https://uae.paymob.com/api/acceptance/iframes/31014?payment_token=...",
        "amount": 10,
        "currency": "AED",
        "expires_in": 3600,
        "status": "pending"
    },
    "message": "Payment initiated successfully. Use the iframe_url for payment processing."
}
```

## Implementation

### 1. BLoC Pattern
The integration uses the BLoC pattern for state management:

**Files Created:**
- `lib/bloc/wallet/wallet_event.dart` - Wallet events
- `lib/bloc/wallet/wallet_state.dart` - Wallet states
- `lib/bloc/wallet/wallet_bloc.dart` - Wallet business logic

**Events:**
- `DepositCashEvent(amount)` - Initiates deposit
- `CheckPaymentStatusEvent(paymentId)` - Checks payment status
- `ResetWalletEvent()` - Resets wallet state

**States:**
- `WalletInitial` - Initial state
- `WalletLoading` - Loading state
- `WalletDepositSuccess(depositResponse)` - Deposit API success
- `WalletPaymentCompleted(message)` - Payment completed
- `WalletError(message)` - Error state

### 2. Data Model
**File**: `lib/model/wallet_model.dart`

Contains:
- `WalletDepositResponse` - Main response model
- `WalletDepositData` - Nested data model with payment details

### 3. UI Components

#### Wallet Screen (`wallet_screen.dart`)
- Displays current balance
- "Add cash on wallet" button opens bottom sheet
- Bottom sheet allows user to enter amount

#### Payment Screen (`payment_screen.dart`)
- Allows user to enter payment amount
- Integrates with `WalletBloc` to initiate deposit
- On success, navigates to WebView screen with iframe URL

#### Payment WebView Screen (`payment_webview_screen.dart`)
- Displays payment gateway iframe
- Monitors URL changes to detect payment completion
- Shows success/failure bottom sheets
- Handles back navigation with exit confirmation

### 4. Dependencies
Added to `pubspec.yaml`:
```yaml
webview_flutter: ^4.11.2
```

## User Flow

1. User navigates to Wallet screen
2. Clicks "Add cash on wallet" button
3. Bottom sheet appears with amount input
4. User enters amount and clicks "Continue to Payment"
5. Payment screen shows with amount
6. User clicks "Continue" button
7. API call is made to `/api/customer/wallet/deposit`
8. On success, WebView screen opens with payment iframe
9. User completes payment in iframe
10. URL change is detected, success sheet is shown
11. User returns to home screen

## Payment Gateway Detection

The WebView monitors URL changes and looks for these keywords:
- **Success**: "success", "callback", "completed"
- **Failure**: "cancel", "failed"

You may need to adjust these based on the actual callback URLs from your payment gateway.

## Error Handling

- Authentication errors (missing token)
- Network errors
- API errors
- WebView loading errors
- Invalid amount validation

All errors are shown via SnackBar with appropriate messages.

## Testing

To test the integration:

1. Ensure user is logged in (has valid auth_token)
2. Navigate to Wallet screen
3. Enter a test amount (e.g., 10.00)
4. Follow the payment flow
5. Check if iframe loads correctly
6. Complete or cancel payment to test different states

## Notes

- The auth token is automatically retrieved from SharedPreferences
- The iframe URL from API response is used directly in WebView
- Payment status can be enhanced with polling or webhook integration
- The current implementation relies on URL pattern matching for status detection


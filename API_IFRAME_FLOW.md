# API Iframe Integration Flow

## ✅ CONFIRMATION: The iframe URL from the API is being used!

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. USER ENTERS AMOUNT                                                │
│    (wallet_screen.dart or payment_screen.dart)                       │
└─────────────────────┬───────────────────────────────────────────────┘
                      │ User clicks "Continue"
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 2. API CALL                                                           │
│    WalletBloc.add(DepositCashEvent(amount: amount))                  │
│    ├─ POST https://onecharge.io/api/customer/wallet/deposit          │
│    ├─ Headers: Authorization: Bearer <token>                         │
│    └─ Body: {"amount": 10.00}                                        │
└─────────────────────┬───────────────────────────────────────────────┘
                      │ API Response
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 3. API RESPONSE RECEIVED                                              │
│    {                                                                  │
│      "success": true,                                                 │
│      "data": {                                                        │
│        "payment_id": "PAY-TYVRDCSUHMFA",                              │
│        "iframe_url": "https://uae.paymob.com/api/acceptance/...",    │
│        "amount": 10,                                                  │
│        "currency": "AED",                                             │
│        "status": "pending"                                            │
│      }                                                                │
│    }                                                                  │
│    ├─ Parsed by WalletDepositResponse.fromJson()                     │
│    └─ State: WalletDepositSuccess(depositResponse)                   │
└─────────────────────┬───────────────────────────────────────────────┘
                      │ iframe_url extracted
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 4. NAVIGATE TO WEBVIEW WITH API IFRAME URL                           │
│    PaymentWebViewScreen(                                              │
│      iframeUrl: depositResponse.data.iframeUrl,  ← FROM API!         │
│      paymentId: depositResponse.data.paymentId,                      │
│      amount: depositResponse.data.amount                             │
│    )                                                                  │
└─────────────────────┬───────────────────────────────────────────────┘
                      │ WebView loads URL
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 5. WEBVIEW LOADS IFRAME                                               │
│    WebViewController()                                                │
│      ..loadRequest(Uri.parse(widget.iframeUrl))  ← USES API URL!     │
│                                                                       │
│    The iframe URL from API is loaded in WebView:                     │
│    https://uae.paymob.com/api/acceptance/iframes/31014?payment_token=│
└─────────────────────┬───────────────────────────────────────────────┘
                      │ User completes payment
                      ▼
┌─────────────────────────────────────────────────────────────────────┐
│ 6. PAYMENT COMPLETION                                                 │
│    - URL changes detected by NavigationDelegate                      │
│    - Success/failure detected from URL patterns                      │
│    - Show appropriate bottom sheet                                   │
└───────────────────────────────────────────────────────────────────────┘
```

## Key Code Locations

### 1. API Call (wallet_bloc.dart)
```dart
// Line 33-43: Makes POST request to deposit API
final response = await http.post(
  Uri.parse('$baseUrl/api/customer/wallet/deposit'),
  headers: {
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({'amount': event.amount}),
);

// Line 48-52: Extracts iframe URL from API response
final depositResponse = WalletDepositResponse.fromJson(data);
print('✅ iframe URL: ${depositResponse.data.iframeUrl}'); // FROM API
emit(WalletDepositSuccess(depositResponse: depositResponse));
```

### 2. Pass iframe URL to WebView (payment_screen.dart)
```dart
// Line 132-144: Listen for success and pass iframe URL
if (state is WalletDepositSuccess) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentWebViewScreen(
        iframeUrl: state.depositResponse.data.iframeUrl, // ← FROM API
        paymentId: state.depositResponse.data.paymentId,
        amount: state.depositResponse.data.amount,
      ),
    ),
  );
}
```

### 3. Load iframe in WebView (payment_webview_screen.dart)
```dart
// Line 32-68: Initialize WebView with API iframe URL
void _initializeWebView() {
  print('🌐 Loading iframe URL from API: ${widget.iframeUrl}');
  
  _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.white)
    ..loadRequest(Uri.parse(widget.iframeUrl)); // ← LOADS API URL
}
```

## Debug Logs

When you run the app, you'll see these logs confirming the API iframe URL is being used:

```
✅ Deposit API Success - iframe URL: https://uae.paymob.com/api/acceptance/iframes/31014?payment_token=...
✅ Payment ID: PAY-TYVRDCSUHMFA
✅ Amount: 10.0 AED
🚀 Navigating to payment iframe...
📍 iframe URL: https://uae.paymob.com/api/acceptance/iframes/31014?payment_token=...
🌐 Loading iframe URL from API: https://uae.paymob.com/api/acceptance/iframes/31014?payment_token=...
💳 Payment ID: PAY-TYVRDCSUHMFA
💰 Amount: AED 10.0
📄 Page started loading: https://uae.paymob.com/api/acceptance/iframes/31014?payment_token=...
✅ Page finished loading: https://uae.paymob.com/...
```

## Summary

✅ **YES**, the iframe URL from your API (`https://onecharge.io/api/customer/wallet/deposit`) is being used!

The flow is:
1. **API Call** → Get iframe_url from response
2. **Extract** → Parse `data.iframe_url` from JSON
3. **Navigate** → Pass iframe_url to PaymentWebViewScreen
4. **Display** → WebView loads the iframe_url using `loadRequest()`

The iframe URL is **never hardcoded** - it always comes directly from your API response!


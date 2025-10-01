// wallet_model.dart
class WalletDepositResponse {
  final bool success;
  final WalletDepositData data;
  final String message;

  WalletDepositResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WalletDepositResponse.fromJson(Map<String, dynamic> json) {
    return WalletDepositResponse(
      success: json['success'] ?? false,
      data: WalletDepositData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class WalletDepositData {
  final String paymentId;
  final int orderId;
  final String paymentToken;
  final String iframeUrl;
  final double amount;
  final String currency;
  final int expiresIn;
  final String status;

  WalletDepositData({
    required this.paymentId,
    required this.orderId,
    required this.paymentToken,
    required this.iframeUrl,
    required this.amount,
    required this.currency,
    required this.expiresIn,
    required this.status,
  });

  factory WalletDepositData.fromJson(Map<String, dynamic> json) {
    return WalletDepositData(
      paymentId: json['payment_id'] ?? '',
      orderId: json['order_id'] ?? 0,
      paymentToken: json['payment_token'] ?? '',
      iframeUrl: json['iframe_url'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'AED',
      expiresIn: json['expires_in'] ?? 3600,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'payment_token': paymentToken,
      'iframe_url': iframeUrl,
      'amount': amount,
      'currency': currency,
      'expires_in': expiresIn,
      'status': status,
    };
  }
}


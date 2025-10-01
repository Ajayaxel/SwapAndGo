// wallet_model.dart
class WalletBalanceResponse {
  final bool success;
  final WalletBalanceData data;
  final String message;

  WalletBalanceResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      success: json['success'] ?? false,
      data: WalletBalanceData.fromJson(json['data']),
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

class WalletBalanceData {
  final int walletId;
  final String balance;
  final int availableBalance;
  final String reservedBalance;
  final String currency;
  final String status;
  final String lastTransactionAt;

  WalletBalanceData({
    required this.walletId,
    required this.balance,
    required this.availableBalance,
    required this.reservedBalance,
    required this.currency,
    required this.status,
    required this.lastTransactionAt,
  });

  factory WalletBalanceData.fromJson(Map<String, dynamic> json) {
    return WalletBalanceData(
      walletId: json['wallet_id'] ?? 0,
      balance: json['balance'] ?? '0.00',
      availableBalance: json['available_balance'] ?? 0,
      reservedBalance: json['reserved_balance'] ?? '0.00',
      currency: json['currency'] ?? 'EGP',
      status: json['status'] ?? 'active',
      lastTransactionAt: json['last_transaction_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'balance': balance,
      'available_balance': availableBalance,
      'reserved_balance': reservedBalance,
      'currency': currency,
      'status': status,
      'last_transaction_at': lastTransactionAt,
    };
  }
}

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


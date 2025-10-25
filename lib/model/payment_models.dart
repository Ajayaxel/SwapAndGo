// model/payment_models.dart

/// Payment initialization request model
class PaymentInitializationRequest {
  final int planId;
  final String? mobileCallbackUrl;

  PaymentInitializationRequest({
    required this.planId,
    this.mobileCallbackUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'mobile_callback_url': mobileCallbackUrl,
    };
  }
}

/// Payment initialization response model
class PaymentInitializationResponse {
  final bool success;
  final String message;
  final PaymentData data;

  PaymentInitializationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentInitializationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitializationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PaymentData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Payment data model
class PaymentData {
  final int subscriptionId;
  final String paymentUrl;
  final String paymentToken;
  final int orderId;
  final String amount;
  final String currency;
  final PaymentPlan plan;

  PaymentData({
    required this.subscriptionId,
    required this.paymentUrl,
    required this.paymentToken,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.plan,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      subscriptionId: json['subscription_id'] ?? 0,
      paymentUrl: json['payment_url'] ?? '',
      paymentToken: json['payment_token'] ?? '',
      orderId: json['order_id'] ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      currency: json['currency'] ?? 'AED',
      plan: PaymentPlan.fromJson(json['plan'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'payment_url': paymentUrl,
      'payment_token': paymentToken,
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'plan': plan.toJson(),
    };
  }
}

/// Payment plan model
class PaymentPlan {
  final int id;
  final String name;
  final String amount;
  final int trialDays;

  PaymentPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.trialDays,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      trialDays: json['trial_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'trial_days': trialDays,
    };
  }
}

/// Payment callback response model
class PaymentCallbackResponse {
  final bool success;
  final String message;
  final String? subscriptionId;
  final String? status;

  PaymentCallbackResponse({
    required this.success,
    required this.message,
    this.subscriptionId,
    this.status,
  });

  factory PaymentCallbackResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCallbackResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      subscriptionId: json['subscription_id']?.toString(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'subscription_id': subscriptionId,
      'status': status,
    };
  }
}

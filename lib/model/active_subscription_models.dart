// model/active_subscription_models.dart
import 'package:flutter/material.dart';

/// Active subscription response model
class ActiveSubscriptionResponse {
  final bool success;
  final String message;
  final ActiveSubscriptionData? data;

  ActiveSubscriptionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ActiveSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? ActiveSubscriptionData.fromJson(json['data']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// Active subscription data model
class ActiveSubscriptionData {
  final int id;
  final int customerId;
  final int subscriptionPlanId;
  final String paymobSubscriptionId;
  final String paymobCustomerId;
  final String? cardToken;
  final String? cardLastFour;
  final String? cardBrand;
  final String status;
  final DateTime startDate;
  final DateTime? trialEndDate;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime nextBillingDate;
  final DateTime? canceledAt;
  final String? cancellationReason;
  final String metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SubscriptionPlan plan;
  final List<SubscriptionTransaction> transactions;

  ActiveSubscriptionData({
    required this.id,
    required this.customerId,
    required this.subscriptionPlanId,
    required this.paymobSubscriptionId,
    required this.paymobCustomerId,
    this.cardToken,
    this.cardLastFour,
    this.cardBrand,
    required this.status,
    required this.startDate,
    this.trialEndDate,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.nextBillingDate,
    this.canceledAt,
    this.cancellationReason,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.plan,
    required this.transactions,
  });

  factory ActiveSubscriptionData.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionData(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      subscriptionPlanId: json['subscription_plan_id'] ?? 0,
      paymobSubscriptionId: json['paymob_subscription_id'] ?? '',
      paymobCustomerId: json['paymob_customer_id'] ?? '',
      cardToken: json['card_token'],
      cardLastFour: json['card_last_four'],
      cardBrand: json['card_brand'],
      status: json['status'] ?? 'inactive',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      trialEndDate: json['trial_end_date'] != null 
          ? DateTime.parse(json['trial_end_date']) 
          : null,
      currentPeriodStart: json['current_period_start'] != null 
          ? DateTime.parse(json['current_period_start']) 
          : DateTime.now(),
      currentPeriodEnd: json['current_period_end'] != null 
          ? DateTime.parse(json['current_period_end']) 
          : DateTime.now(),
      nextBillingDate: json['next_billing_date'] != null 
          ? DateTime.parse(json['next_billing_date']) 
          : DateTime.now(),
      canceledAt: json['canceled_at'] != null 
          ? DateTime.parse(json['canceled_at']) 
          : null,
      cancellationReason: json['cancellation_reason'],
      metadata: json['metadata'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at']) 
          : null,
      plan: json['plan'] != null 
          ? SubscriptionPlan.fromJson(json['plan']) 
          : SubscriptionPlan.empty(),
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((e) => SubscriptionTransaction.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'subscription_plan_id': subscriptionPlanId,
      'paymob_subscription_id': paymobSubscriptionId,
      'paymob_customer_id': paymobCustomerId,
      'card_token': cardToken,
      'card_last_four': cardLastFour,
      'card_brand': cardBrand,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'trial_end_date': trialEndDate?.toIso8601String(),
      'current_period_start': currentPeriodStart.toIso8601String(),
      'current_period_end': currentPeriodEnd.toIso8601String(),
      'next_billing_date': nextBillingDate.toIso8601String(),
      'canceled_at': canceledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'plan': plan.toJson(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  /// Get formatted start date
  String get formattedStartDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
  }

  /// Get formatted next billing date
  String get formattedNextBillingDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[nextBillingDate.month - 1]} ${nextBillingDate.day}, ${nextBillingDate.year}';
  }

  /// Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xff4CAF50);
      case 'inactive':
      case 'cancelled':
        return const Color(0xffF44336);
      case 'pending':
        return const Color(0xffFF9800);
      case 'trial':
        return const Color(0xff2196F3);
      default:
        return const Color(0xff757575);
    }
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      case 'trial':
        return 'Trial';
      default:
        return status.toUpperCase();
    }
  }

  /// Check if subscription is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Get days until next billing
  int get daysUntilNextBilling {
    final now = DateTime.now();
    final difference = nextBillingDate.difference(now);
    return difference.inDays;
  }
}

/// Subscription plan model
class SubscriptionPlan {
  final int id;
  final String? paymobPlanId;
  final String name;
  final String? description;
  final String amount;
  final String currency;
  final String interval;
  final int intervalCount;
  final int trialPeriodDays;
  final String? features;
  final int maxBatteries;
  final int? maxSwapsPerMonth;
  final bool priorityAccess;
  final bool freeDelivery;
  final String status;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SubscriptionPlan({
    required this.id,
    this.paymobPlanId,
    required this.name,
    this.description,
    required this.amount,
    required this.currency,
    required this.interval,
    required this.intervalCount,
    required this.trialPeriodDays,
    this.features,
    required this.maxBatteries,
    this.maxSwapsPerMonth,
    required this.priorityAccess,
    required this.freeDelivery,
    required this.status,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      paymobPlanId: json['paymob_plan_id'],
      name: json['name'] ?? '',
      description: json['description'],
      amount: json['amount']?.toString() ?? '0.00',
      currency: json['currency'] ?? 'AED',
      interval: json['interval'] ?? 'month',
      intervalCount: json['interval_count'] ?? 1,
      trialPeriodDays: json['trial_period_days'] ?? 0,
      features: json['features'],
      maxBatteries: json['max_batteries'] ?? 0,
      maxSwapsPerMonth: json['max_swaps_per_month'],
      priorityAccess: json['priority_access'] ?? false,
      freeDelivery: json['free_delivery'] ?? false,
      status: json['status'] ?? 'inactive',
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at']) 
          : null,
    );
  }

  factory SubscriptionPlan.empty() {
    return SubscriptionPlan(
      id: 0,
      name: '',
      amount: '0.00',
      currency: 'AED',
      interval: 'month',
      intervalCount: 1,
      trialPeriodDays: 0,
      maxBatteries: 0,
      priorityAccess: false,
      freeDelivery: false,
      status: 'inactive',
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymob_plan_id': paymobPlanId,
      'name': name,
      'description': description,
      'amount': amount,
      'currency': currency,
      'interval': interval,
      'interval_count': intervalCount,
      'trial_period_days': trialPeriodDays,
      'features': features,
      'max_batteries': maxBatteries,
      'max_swaps_per_month': maxSwapsPerMonth,
      'priority_access': priorityAccess,
      'free_delivery': freeDelivery,
      'status': status,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Get formatted amount
  String get formattedAmount {
    return '$amount $currency';
  }

  /// Get interval display text
  String get intervalDisplayText {
    switch (interval.toLowerCase()) {
      case 'month':
        return intervalCount == 1 ? 'Monthly' : 'Every $intervalCount months';
      case 'year':
        return intervalCount == 1 ? 'Yearly' : 'Every $intervalCount years';
      case 'week':
        return intervalCount == 1 ? 'Weekly' : 'Every $intervalCount weeks';
      case 'day':
        return intervalCount == 1 ? 'Daily' : 'Every $intervalCount days';
      default:
        return 'Every $intervalCount $interval';
    }
  }

  /// Get plan features as list
  List<String> get planFeatures {
    final featuresList = <String>[];
    
    if (maxBatteries > 0) {
      featuresList.add('Max $maxBatteries batteries');
    }
    
    if (maxSwapsPerMonth != null && maxSwapsPerMonth! > 0) {
      featuresList.add('$maxSwapsPerMonth swaps per month');
    }
    
    if (priorityAccess) {
      featuresList.add('Priority access');
    }
    
    if (freeDelivery) {
      featuresList.add('Free delivery');
    }
    
    if (features != null && features!.isNotEmpty) {
      try {
        final additionalFeatures = features!.split(',');
        featuresList.addAll(additionalFeatures.map((f) => f.trim()));
      } catch (e) {
        // If parsing fails, add as single feature
        featuresList.add(features!);
      }
    }
    
    return featuresList;
  }
}

/// Subscription transaction model
class SubscriptionTransaction {
  final int id;
  final int customerSubscriptionId;
  final String paymobTransactionId;
  final String? transactionReference;
  final String amount;
  final String currency;
  final String status;
  final String? failureReason;
  final DateTime billingDate;
  final DateTime? paidAt;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionTransaction({
    required this.id,
    required this.customerSubscriptionId,
    required this.paymobTransactionId,
    this.transactionReference,
    required this.amount,
    required this.currency,
    required this.status,
    this.failureReason,
    required this.billingDate,
    this.paidAt,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionTransaction.fromJson(Map<String, dynamic> json) {
    return SubscriptionTransaction(
      id: json['id'] ?? 0,
      customerSubscriptionId: json['customer_subscription_id'] ?? 0,
      paymobTransactionId: json['paymob_transaction_id'] ?? '',
      transactionReference: json['transaction_reference'],
      amount: json['amount']?.toString() ?? '0.00',
      currency: json['currency'] ?? 'AED',
      status: json['status'] ?? 'pending',
      failureReason: json['failure_reason'],
      billingDate: json['billing_date'] != null 
          ? DateTime.parse(json['billing_date']) 
          : DateTime.now(),
      paidAt: json['paid_at'] != null 
          ? DateTime.parse(json['paid_at']) 
          : null,
      metadata: json['metadata'] ?? {},
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_subscription_id': customerSubscriptionId,
      'paymob_transaction_id': paymobTransactionId,
      'transaction_reference': transactionReference,
      'amount': amount,
      'currency': currency,
      'status': status,
      'failure_reason': failureReason,
      'billing_date': billingDate.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get formatted amount
  String get formattedAmount {
    return '$amount $currency';
  }

  /// Get formatted billing date
  String get formattedBillingDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[billingDate.month - 1]} ${billingDate.day}, ${billingDate.year}';
  }

  /// Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'succeeded':
      case 'completed':
      case 'success':
        return const Color(0xff4CAF50);
      case 'pending':
        return const Color(0xffFF9800);
      case 'failed':
      case 'cancelled':
        return const Color(0xffF44336);
      default:
        return const Color(0xff757575);
    }
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return 'Succeeded';
      case 'completed':
        return 'Completed';
      case 'success':
        return 'Success';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
}

/// Custom exception class for active subscription API errors
class ActiveSubscriptionException implements Exception {
  final String message;
  final int statusCode;
  
  const ActiveSubscriptionException(this.message, this.statusCode);
  
  @override
  String toString() => 'ActiveSubscriptionException: $message (Status: $statusCode)';
}

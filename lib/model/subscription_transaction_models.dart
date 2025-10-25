// model/subscription_transaction_models.dart
import 'package:flutter/material.dart';

/// Subscription transaction response model matching new API structure
class SubscriptionTransactionResponse {
  final bool success;
  final String message;
  final SubscriptionTransactionData? data;

  SubscriptionTransactionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SubscriptionTransactionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionTransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? SubscriptionTransactionData.fromJson(json['data']) 
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

/// Data wrapper for subscription transactions
class SubscriptionTransactionData {
  final List<SubscriptionTransaction> transactions;
  final int count;
  final int totalPaid;

  SubscriptionTransactionData({
    required this.transactions,
    required this.count,
    required this.totalPaid,
  });

  factory SubscriptionTransactionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionTransactionData(
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((e) => SubscriptionTransaction.fromJson(e))
              .toList()
          : [],
      count: json['count'] ?? 0,
      totalPaid: json['total_paid'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'count': count,
      'total_paid': totalPaid,
    };
  }
}

/// Individual subscription transaction model matching new API structure
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

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}';
  }

  /// Get formatted billing date string
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
        return Color(0xff4CAF50);
      case 'pending':
        return Color(0xffFF9800);
      case 'failed':
      case 'cancelled':
        return Color(0xffF44336);
      default:
        return Color(0xff757575);
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

  /// Get payment method from metadata
  String get paymentMethod {
    final sourceDataType = metadata['source_data_type']?.toString() ?? '';
    final sourceDataSubType = metadata['source_data_sub_type']?.toString() ?? '';
    
    if (sourceDataType == 'card') {
      return sourceDataSubType.isNotEmpty ? sourceDataSubType : 'Card';
    }
    return sourceDataType.isNotEmpty ? sourceDataType : 'Unknown';
  }

  /// Get transaction reference for display
  String get displayTransactionId {
    return paymobTransactionId.isNotEmpty ? paymobTransactionId : 'N/A';
  }
}

/// Subscription plan model for transaction history
class SubscriptionPlan {
  final int id;
  final String name;
  final String amount;
  final String currency;
  final int swappingSessions;
  final String billingCycle;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.swappingSessions,
    required this.billingCycle,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      currency: json['currency'] ?? 'AED',
      swappingSessions: json['swapping_sessions'] ?? 0,
      billingCycle: json['billing_cycle'] ?? 'monthly',
      isActive: json['is_active'] ?? false,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'currency': currency,
      'swapping_sessions': swappingSessions,
      'billing_cycle': billingCycle,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

/// Custom exception class for subscription transaction API errors
class SubscriptionTransactionException implements Exception {
  final String message;
  final int statusCode;
  
  const SubscriptionTransactionException(this.message, this.statusCode);
  
  @override
  String toString() => 'SubscriptionTransactionException: $message (Status: $statusCode)';
}

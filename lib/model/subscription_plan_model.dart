// model/subscription_plan_model.dart

/// Subscription plan model
class SubscriptionPlan {
  final int id;
  final String? paymobPlanId;
  final String name;
  final String description;
  final String amount;
  final String currency;
  final String interval;
  final int intervalCount;
  final int trialPeriodDays;
  final dynamic features;
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
    required this.description,
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
      description: json['description'] ?? '',
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
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: json['deleted_at'] != null 
          ? _parseDateTime(json['deleted_at']) 
          : null,
    );
  }

  /// Parse datetime string safely
  static DateTime _parseDateTime(dynamic dateTimeStr) {
    try {
      if (dateTimeStr == null) return DateTime.now();
      return DateTime.parse(dateTimeStr.toString());
    } catch (e) {
      print('Error parsing datetime: $e');
      return DateTime.now();
    }
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

  /// Get formatted price
  String get formattedPrice => '$currency $amount';

  /// Get formatted interval
  String get formattedInterval {
    if (intervalCount == 1) {
      return '/$interval';
    } else {
      return '/$intervalCount ${interval}s';
    }
  }

  /// Check if plan is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Get swaps text (unlimited or specific count)
  String get swapsText {
    if (maxSwapsPerMonth == null) {
      return 'Unlimited swaps';
    } else {
      return '$maxSwapsPerMonth swap${maxSwapsPerMonth! > 1 ? 's' : ''} per month';
    }
  }

  /// Get plan features list
  List<String> get featuresList {
    final list = <String>[];
    
    // Add swaps info
    list.add(swapsText);
    
    // Add batteries info
    list.add('Up to $maxBatteries ${maxBatteries > 1 ? 'batteries' : 'battery'}');
    
    // Add priority access
    if (priorityAccess) {
      list.add('Priority access');
    }
    
    // Add free delivery
    if (freeDelivery) {
      list.add('Free delivery');
    }
    
    return list;
  }
}

/// Subscription plans response model
class SubscriptionPlansResponse {
  final bool success;
  final String message;
  final List<SubscriptionPlan> plans;
  final int count;

  SubscriptionPlansResponse({
    required this.success,
    required this.message,
    required this.plans,
    required this.count,
  });

  factory SubscriptionPlansResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>;
    final plans = (dataMap['plans'] as List<dynamic>)
        .map((item) => SubscriptionPlan.fromJson(item as Map<String, dynamic>))
        .toList();

    return SubscriptionPlansResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      plans: plans,
      count: dataMap['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'plans': plans.map((plan) => plan.toJson()).toList(),
        'count': count,
      },
    };
  }
}


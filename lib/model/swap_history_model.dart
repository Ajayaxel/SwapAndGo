// model/swap_history_model.dart

/// Battery model for swap history
class Battery {
  final String id;
  final String batteryCode;
  final String status;
  final String healthStatus;
  final String currentCharge;
  final String maxCharge;

  Battery({
    required this.id,
    required this.batteryCode,
    required this.status,
    required this.healthStatus,
    required this.currentCharge,
    required this.maxCharge,
  });

  factory Battery.fromJson(Map<String, dynamic> json) {
    return Battery(
      id: json['id'] ?? '',
      batteryCode: json['battery_code'] ?? '',
      status: json['status'] ?? '',
      healthStatus: json['health_status'] ?? '',
      currentCharge: json['current_charge'] ?? '0',
      maxCharge: json['max_charge'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'battery_code': batteryCode,
      'status': status,
      'health_status': healthStatus,
      'current_charge': currentCharge,
      'max_charge': maxCharge,
    };
  }

  /// Get charge percentage
  double get chargePercentage {
    final current = double.tryParse(currentCharge) ?? 0;
    final max = double.tryParse(maxCharge) ?? 1;
    return max > 0 ? (current / max) * 100 : 0;
  }
}

/// Station model for swap history (simplified)
class SwapStation {
  final String id;
  final String name;
  final String? address;
  final String? city;

  SwapStation({
    required this.id,
    required this.name,
    this.address,
    this.city,
  });

  factory SwapStation.fromJson(Map<String, dynamic> json) {
    return SwapStation(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
    };
  }
}

/// Swap transaction model
class SwapTransaction {
  final int id;
  final int customerId;
  final String batteryId;
  final String transactionType;
  final String? stationId;
  final String? notes;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Battery? battery;
  final SwapStation? station;

  SwapTransaction({
    required this.id,
    required this.customerId,
    required this.batteryId,
    required this.transactionType,
    this.stationId,
    this.notes,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.battery,
    this.station,
  });

  factory SwapTransaction.fromJson(Map<String, dynamic> json) {
    return SwapTransaction(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      batteryId: json['battery_id'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      stationId: json['station_id']?.toString(),
      notes: json['notes'],
      transactionDate: _parseToIST(
        json['transaction_date'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: _parseToIST(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: _parseToIST(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      battery: json['battery'] != null 
          ? Battery.fromJson(json['battery'] as Map<String, dynamic>)
          : null,
      station: json['station'] != null 
          ? SwapStation.fromJson(json['station'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Parse datetime string and convert to IST (UTC+5:30)
  static DateTime _parseToIST(String dateTimeStr) {
    try {
      // Parse the datetime string
      DateTime parsedDate = DateTime.parse(dateTimeStr);
      
      // If it's already in UTC, convert to IST
      if (parsedDate.isUtc) {
        // IST is UTC + 5 hours 30 minutes
        return parsedDate.add(const Duration(hours: 5, minutes: 30));
      }
      
      // If it's in local time, convert to UTC first, then to IST
      // This assumes the API sends UTC or IST timestamps
      return parsedDate.toUtc().add(const Duration(hours: 5, minutes: 30));
    } catch (e) {
      print('Error parsing datetime: $e');
      // Return current time in IST if parsing fails
      return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'battery_id': batteryId,
      'transaction_type': transactionType,
      'station_id': stationId,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'battery': battery?.toJson(),
      'station': station?.toJson(),
    };
  }

  /// Get formatted transaction type
  String get formattedType {
    return transactionType == 'checkout' ? 'Swap Completed' : 'Swap In Progress';
  }

  /// Check if transaction is completed
  bool get isCompleted => transactionType == 'checkout';
}

/// Pagination model
class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
    };
  }

  /// Check if there are more pages
  bool get hasNextPage => currentPage < lastPage;

  /// Check if there is a previous page
  bool get hasPreviousPage => currentPage > 1;
}

/// Swap history response model
class SwapHistoryResponse {
  final bool success;
  final List<SwapTransaction> data;
  final Pagination pagination;
  final String message;

  SwapHistoryResponse({
    required this.success,
    required this.data,
    required this.pagination,
    required this.message,
  });

  factory SwapHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>;
    final transactions = (dataMap['data'] as List<dynamic>)
        .map((item) => SwapTransaction.fromJson(item as Map<String, dynamic>))
        .toList();

    return SwapHistoryResponse(
      success: json['success'] ?? false,
      data: transactions,
      pagination: Pagination.fromJson(
        dataMap['pagination'] as Map<String, dynamic>,
      ),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'data': data.map((item) => item.toJson()).toList(),
        'pagination': pagination.toJson(),
      },
      'message': message,
    };
  }
}


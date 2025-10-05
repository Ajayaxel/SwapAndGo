class QrCodeModel {
  final String qrCode;
  final DateTime scannedAt;
  final QrCodeStatus status;
  final Map<String, dynamic>? data;
  final String? message;
  final String? error;

  const QrCodeModel({
    required this.qrCode,
    required this.scannedAt,
    required this.status,
    this.data,
    this.message,
    this.error,
  });

  QrCodeModel copyWith({
    String? qrCode,
    DateTime? scannedAt,
    QrCodeStatus? status,
    Map<String, dynamic>? data,
    String? message,
    String? error,
  }) {
    return QrCodeModel(
      qrCode: qrCode ?? this.qrCode,
      scannedAt: scannedAt ?? this.scannedAt,
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_code': qrCode,
      'scanned_at': scannedAt.toIso8601String(),
      'status': status.name,
      'data': data,
      'message': message,
      'error': error,
    };
  }

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      qrCode: json['qr_code'] ?? '',
      scannedAt: DateTime.parse(json['scanned_at'] ?? DateTime.now().toIso8601String()),
      status: QrCodeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QrCodeStatus.pending,
      ),
      data: json['data'],
      message: json['message'],
      error: json['error'],
    );
  }
}

enum QrCodeStatus {
  pending,
  loading,
  success,
  error,
}

class QrCodeCheckoutRequest {
  final String qrCode;

  const QrCodeCheckoutRequest({required this.qrCode});

  Map<String, dynamic> toJson() {
    return {
      'qr_code': qrCode,
    };
  }
}

class QrCodeCheckoutResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final String? error;

  const QrCodeCheckoutResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory QrCodeCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeCheckoutResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
    };
  }
}

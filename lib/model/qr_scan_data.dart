// lib/models/qr_scan_data.dart

class QRScanData {
  final String batteryCode;
  final String model;
  final String manufacturer;
  final String id;
  final String timestamp;

  QRScanData({
    required this.batteryCode,
    required this.model,
    required this.manufacturer,
    required this.id,
    required this.timestamp,
  });

  factory QRScanData.fromJson(Map<String, dynamic> json) {
    return QRScanData(
      batteryCode: json['battery_code'] ?? '',
      model: json['model'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battery_code': batteryCode,
      'model': model,
      'manufacturer': manufacturer,
      'id': id,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'QRScanData{batteryCode: $batteryCode, model: $model, manufacturer: $manufacturer, id: $id, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QRScanData &&
          runtimeType == other.runtimeType &&
          batteryCode == other.batteryCode &&
          model == other.model &&
          manufacturer == other.manufacturer &&
          id == other.id &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      batteryCode.hashCode ^
      model.hashCode ^
      manufacturer.hashCode ^
      id.hashCode ^
      timestamp.hashCode;
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:swap_app/services/storage_helper.dart';
import '../model/qr_code_model.dart';

class QrCodeService {
  static final QrCodeService _instance = QrCodeService._internal();
  factory QrCodeService() => _instance;
  QrCodeService._internal();

  static const String baseUrl = 'https://onecharge.io';
  static const String checkoutEndpoint = '/api/customer/swap/qr-checkout';

  /// Process QR code checkout
  Future<QrCodeCheckoutResponse> processQrCheckout(String qrCode) async {
    try {
      final request = QrCodeCheckoutRequest(qrCode: qrCode);
      final url = Uri.parse('$baseUrl$checkoutEndpoint');
      final token = await StorageHelper.getString('auth_token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );
      // for debug mode
      // if(kDebugMode){
      //   return QrCodeCheckoutResponse(
      //     success: true,
          
      //   );
      // }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return QrCodeCheckoutResponse.fromJson(responseData);
      } else {
        return QrCodeCheckoutResponse(
          success: false,
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return QrCodeCheckoutResponse(
        success: false,
        error: 'Network error: $e',
      );
    }
  }

  /// Validate QR code format
  bool isValidQrCode(String qrCode) {
    // Basic validation - adjust pattern as needed
    return qrCode.isNotEmpty && qrCode.length >= 5;
  }
}

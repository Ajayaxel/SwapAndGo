// services/subscription_payment_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/payment_models.dart';
import 'package:swap_app/services/storage_helper.dart';

class SubscriptionPaymentService {
  final String baseUrl = "https://onecharge.io";
  static const Duration _timeout = Duration(seconds: 60);

  /// Initialize payment for subscription
  Future<PaymentInitializationResponse> initializePayment({
    required int planId,
  }) async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw SubscriptionPaymentException(
          "Authentication required. Please login again.",
          401,
          
        );
      }

      final uri = Uri.parse('$baseUrl/api/customer/subscription/initialize-payment');

      final request = PaymentInitializationRequest(
        planId: planId,
        mobileCallbackUrl: null,
      );

      print('🔍 Initializing payment for plan: $planId');
      print('📡 Request body: ${json.encode(request.toJson())}');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      ).timeout(_timeout);

      print('📡 Payment Initialization API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final paymentResponse = PaymentInitializationResponse.fromJson(jsonData);
        print('✅ Payment initialized successfully');
        return paymentResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw SubscriptionPaymentException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 403) {
        print('❌ Access forbidden');
        throw SubscriptionPaymentException(
          "Access denied. You don't have permission to initialize payments.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ Plan not found');
        throw SubscriptionPaymentException(
          "Subscription plan not found.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw SubscriptionPaymentException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to initialize payment";
        throw SubscriptionPaymentException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw SubscriptionPaymentException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw SubscriptionPaymentException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw SubscriptionPaymentException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw SubscriptionPaymentException("Invalid response format from server.", 0);
    } on SubscriptionPaymentException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw SubscriptionPaymentException(
        "An unexpected error occurred: ${e.toString()}",
        0,
      );
    }
  }

  /// Check payment status
  Future<PaymentCallbackResponse> checkPaymentStatus({
    required String subscriptionId,
  }) async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw SubscriptionPaymentException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse('$baseUrl/api/customer/subscription/$subscriptionId/status');

      print('🔍 Checking payment status for subscription: $subscriptionId');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📡 Payment Status API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final statusResponse = PaymentCallbackResponse.fromJson(jsonData);
        print('✅ Payment status checked successfully');
        return statusResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw SubscriptionPaymentException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ Subscription not found');
        throw SubscriptionPaymentException(
          "Subscription not found.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw SubscriptionPaymentException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to check payment status";
        throw SubscriptionPaymentException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw SubscriptionPaymentException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw SubscriptionPaymentException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw SubscriptionPaymentException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw SubscriptionPaymentException("Invalid response format from server.", 0);
    } on SubscriptionPaymentException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw SubscriptionPaymentException(
        "An unexpected error occurred: ${e.toString()}",
        0,
      );
    }
  }

  /// Check network connectivity
  Future<void> checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw SubscriptionPaymentException("No internet connection available.", 0);
      }
    } on SocketException {
      throw SubscriptionPaymentException(
        "No internet connection. Please check your network.",
        0,
      );
    }
  }
}

/// Custom exception class for subscription payment API errors
class SubscriptionPaymentException implements Exception {
  final String message;
  final int statusCode;
  
  const SubscriptionPaymentException(this.message, this.statusCode);
  
  @override
  String toString() => 'SubscriptionPaymentException: $message (Status: $statusCode)';
}

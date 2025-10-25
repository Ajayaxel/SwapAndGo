// services/active_subscription_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/active_subscription_models.dart';
import 'package:swap_app/services/storage_helper.dart';

class ActiveSubscriptionService {
  final String baseUrl = "https://onecharge.io";
  static const Duration _timeout = Duration(seconds: 30);

  /// Get active subscription details
  Future<ActiveSubscriptionResponse> getActiveSubscription() async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw ActiveSubscriptionException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse('$baseUrl/api/customer/subscription/my-subscription');

      print('🔍 Fetching active subscription details');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📡 Active Subscription API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final subscriptionResponse = ActiveSubscriptionResponse.fromJson(jsonData);
        print('✅ Active subscription fetched successfully');
        return subscriptionResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw ActiveSubscriptionException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 403) {
        print('❌ Access forbidden');
        throw ActiveSubscriptionException(
          "Access denied. You don't have permission to view subscription details.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ No active subscription found');
        throw ActiveSubscriptionException(
          "No active subscription found. Please subscribe to a plan first.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw ActiveSubscriptionException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to fetch active subscription";
        throw ActiveSubscriptionException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw ActiveSubscriptionException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw ActiveSubscriptionException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw ActiveSubscriptionException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw ActiveSubscriptionException("Invalid response format from server.", 0);
    } on ActiveSubscriptionException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ActiveSubscriptionException(
        "An unexpected error occurred: ${e.toString()}",
        0,
      );
    }
  }

  /// Cancel active subscription
  Future<ActiveSubscriptionResponse> cancelSubscription({
    String? reason,
  }) async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw ActiveSubscriptionException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse('$baseUrl/api/customer/subscription/cancel');

      print('🔍 Cancelling active subscription');
      
      final requestBody = <String, dynamic>{
        'reason': reason ?? 'No longer needed',
      };
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(_timeout);

      print('📡 Cancel Subscription API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final subscriptionResponse = ActiveSubscriptionResponse.fromJson(jsonData);
        print('✅ Subscription cancelled successfully');
        return subscriptionResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw ActiveSubscriptionException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ No active subscription found to cancel');
        throw ActiveSubscriptionException(
          "No active subscription found to cancel.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw ActiveSubscriptionException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to cancel subscription";
        throw ActiveSubscriptionException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw ActiveSubscriptionException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw ActiveSubscriptionException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw ActiveSubscriptionException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw ActiveSubscriptionException("Invalid response format from server.", 0);
    } on ActiveSubscriptionException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ActiveSubscriptionException(
        "An unexpected error occurred: ${e.toString()}",
        0,
      );
    }
  }

  /// Update subscription payment method
  Future<ActiveSubscriptionResponse> updatePaymentMethod({
    required String cardToken,
    String? cardLastFour,
    String? cardBrand,
  }) async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw ActiveSubscriptionException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse('$baseUrl/api/customer/subscription/update-payment-method');

      print('🔍 Updating subscription payment method');
      
      final requestBody = <String, dynamic>{
        'card_token': cardToken,
      };
      
      if (cardLastFour != null) {
        requestBody['card_last_four'] = cardLastFour;
      }
      
      if (cardBrand != null) {
        requestBody['card_brand'] = cardBrand;
      }
      
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(_timeout);

      print('📡 Update Payment Method API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final subscriptionResponse = ActiveSubscriptionResponse.fromJson(jsonData);
        print('✅ Payment method updated successfully');
        return subscriptionResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw ActiveSubscriptionException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ No active subscription found');
        throw ActiveSubscriptionException(
          "No active subscription found.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw ActiveSubscriptionException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to update payment method";
        throw ActiveSubscriptionException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw ActiveSubscriptionException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw ActiveSubscriptionException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw ActiveSubscriptionException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw ActiveSubscriptionException("Invalid response format from server.", 0);
    } on ActiveSubscriptionException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ActiveSubscriptionException(
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
        throw ActiveSubscriptionException("No internet connection available.", 0);
      }
    } on SocketException {
      throw ActiveSubscriptionException(
        "No internet connection. Please check your network.",
        0,
      );
    }
  }
}

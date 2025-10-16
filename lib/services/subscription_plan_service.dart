// services/subscription_plan_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/subscription_plan_model.dart';
import 'package:swap_app/services/storage_helper.dart';

class SubscriptionPlanService {
  final String baseUrl = "https://onecharge.io/api/customer/subscription/plans";
  static const Duration _timeout = Duration(seconds: 60);

  /// Fetch subscription plans
  Future<SubscriptionPlansResponse> fetchSubscriptionPlans() async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw SubscriptionPlanException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse(baseUrl);

      print('🔍 Fetching subscription plans from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📡 Subscription Plans API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final subscriptionPlansResponse = SubscriptionPlansResponse.fromJson(jsonData);
        print('✅ Successfully loaded ${subscriptionPlansResponse.plans.length} subscription plans');
        return subscriptionPlansResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw SubscriptionPlanException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 403) {
        print('❌ Access forbidden');
        throw SubscriptionPlanException(
          "Access denied. You don't have permission to view subscription plans.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ Subscription plans not found');
        throw SubscriptionPlanException(
          "No subscription plans found.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw SubscriptionPlanException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to load subscription plans";
        throw SubscriptionPlanException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw SubscriptionPlanException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw SubscriptionPlanException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw SubscriptionPlanException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw SubscriptionPlanException("Invalid response format from server.", 0);
    } on SubscriptionPlanException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw SubscriptionPlanException(
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
        throw SubscriptionPlanException("No internet connection available.", 0);
      }
    } on SocketException {
      throw SubscriptionPlanException(
        "No internet connection. Please check your network.",
        0,
      );
    }
  }
}

/// Custom exception class for subscription plan API errors
class SubscriptionPlanException implements Exception {
  final String message;
  final int statusCode;
  
  const SubscriptionPlanException(this.message, this.statusCode);
  
  @override
  String toString() => 'SubscriptionPlanException: $message (Status: $statusCode)';
}


// services/subscription_transaction_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/subscription_transaction_models.dart';
import 'package:swap_app/services/storage_helper.dart';

class SubscriptionTransactionService {
  final String baseUrl = "https://onecharge.io";
  static const Duration _timeout = Duration(seconds: 30);

  /// Get subscription transactions
  Future<SubscriptionTransactionResponse> getSubscriptionTransactions() async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw SubscriptionTransactionException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse('$baseUrl/api/customer/subscription/transactions');

      print('🔍 Fetching subscription transactions');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📡 Subscription Transactions API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final transactionResponse = SubscriptionTransactionResponse.fromJson(jsonData);
        print('✅ Subscription transactions fetched successfully');
        return transactionResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw SubscriptionTransactionException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 403) {
        print('❌ Access forbidden');
        throw SubscriptionTransactionException(
          "Access denied. You don't have permission to view transactions.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ No subscription found');
        throw SubscriptionTransactionException(
          "No active subscription found. Please subscribe to a plan first.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw SubscriptionTransactionException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to fetch subscription transactions";
        throw SubscriptionTransactionException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw SubscriptionTransactionException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw SubscriptionTransactionException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw SubscriptionTransactionException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw SubscriptionTransactionException("Invalid response format from server.", 0);
    } on SubscriptionTransactionException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw SubscriptionTransactionException(
        "An unexpected error occurred: ${e.toString()}",
        0,
      );
    }
  }

  /// Get transaction details by ID
  Future<SubscriptionTransaction> getTransactionDetails({
    required int transactionId,
  }) async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw SubscriptionTransactionException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse('$baseUrl/api/customer/subscription/transactions/$transactionId');

      print('🔍 Fetching transaction details for ID: $transactionId');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📡 Transaction Details API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final transaction = SubscriptionTransaction.fromJson(jsonData);
        print('✅ Transaction details fetched successfully');
        return transaction;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw SubscriptionTransactionException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ Transaction not found');
        throw SubscriptionTransactionException(
          "Transaction not found.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw SubscriptionTransactionException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to fetch transaction details";
        throw SubscriptionTransactionException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw SubscriptionTransactionException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw SubscriptionTransactionException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw SubscriptionTransactionException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw SubscriptionTransactionException("Invalid response format from server.", 0);
    } on SubscriptionTransactionException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw SubscriptionTransactionException(
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
        throw SubscriptionTransactionException("No internet connection available.", 0);
      }
    } on SocketException {
      throw SubscriptionTransactionException(
        "No internet connection. Please check your network.",
        0,
      );
    }
  }
}

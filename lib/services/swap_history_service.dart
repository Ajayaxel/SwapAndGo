// services/swap_history_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/swap_history_model.dart';
import 'package:swap_app/services/storage_helper.dart';

class SwapHistoryService {
  final String baseUrl = "https://onecharge.io/api/customer/swap/history";
  static const Duration _timeout = Duration(seconds: 60);

  /// Fetch swap history with pagination
  Future<SwapHistoryResponse> fetchSwapHistory({
    int limit = 20,
    int page = 1,
  }) async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw SwapHistoryException(
          "Authentication required. Please login again.",
          401,
        );
      }

      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'limit': limit.toString(),
          'page': page.toString(),
        },
      );

      print('🔍 Fetching swap history from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📡 Swap History API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final swapHistoryResponse = SwapHistoryResponse.fromJson(jsonData);
        print('✅ Successfully loaded ${swapHistoryResponse.data.length} swap transactions');
        return swapHistoryResponse;
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw SwapHistoryException(
          "Authentication failed. Please login again.",
          response.statusCode,
        );
      } else if (response.statusCode == 403) {
        print('❌ Access forbidden');
        throw SwapHistoryException(
          "Access denied. You don't have permission to view swap history.",
          response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('❌ Swap history not found');
        throw SwapHistoryException(
          "No swap history found.",
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw SwapHistoryException(
          "Server error. Please try again later.",
          response.statusCode,
        );
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? "Failed to load swap history";
        throw SwapHistoryException(errorMessage, response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw SwapHistoryException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw SwapHistoryException(
        "No internet connection. Please check your network and try again.",
        0,
      );
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw SwapHistoryException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw SwapHistoryException("Invalid response format from server.", 0);
    } on SwapHistoryException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw SwapHistoryException(
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
        throw SwapHistoryException("No internet connection available.", 0);
      }
    } on SocketException {
      throw SwapHistoryException(
        "No internet connection. Please check your network.",
        0,
      );
    }
  }
}

/// Custom exception class for swap history API errors
class SwapHistoryException implements Exception {
  final String message;
  final int statusCode;
  
  const SwapHistoryException(this.message, this.statusCode);
  
  @override
  String toString() => 'SwapHistoryException: $message (Status: $statusCode)';
}


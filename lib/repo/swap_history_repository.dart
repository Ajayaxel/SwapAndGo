// repository/swap_history_repository.dart
import 'dart:async';
import 'dart:io';
import 'package:swap_app/model/swap_history_model.dart';
import 'package:swap_app/services/swap_history_service.dart';

class SwapHistoryRepository {
  final SwapHistoryService _service = SwapHistoryService();

  /// Fetch swap history with retry logic
  Future<SwapHistoryResponse> fetchSwapHistory({
    int limit = 20,
    int page = 1,
  }) async {
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check network connectivity first
        await _service.checkNetworkConnectivity();
        
        // Fetch swap history
        final response = await _service.fetchSwapHistory(
          limit: limit,
          page: page,
        );
        
        return response;
      } on SwapHistoryException {
        // Don't retry on authentication or permission errors
        rethrow;
      } on TimeoutException {
        print('❌ Request timeout (Attempt ${retryCount + 1}/$maxRetries)');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SwapHistoryException("Request timeout. Please try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on SocketException {
        print('❌ Network error (Attempt ${retryCount + 1}/$maxRetries)');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SwapHistoryException(
            "No internet connection. Please check your network and try again.",
            0,
          );
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on HttpException catch (e) {
        print('❌ HTTP Exception (Attempt ${retryCount + 1}/$maxRetries): $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SwapHistoryException("Network error: ${e.message}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on FormatException catch (e) {
        print('❌ Format Exception: $e');
        // Don't retry on format errors
        throw SwapHistoryException("Invalid response format from server.", 0);
      } catch (e) {
        print('❌ Unexpected error (Attempt ${retryCount + 1}/$maxRetries): $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SwapHistoryException(
            "An unexpected error occurred: ${e.toString()}",
            0,
          );
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    
    throw SwapHistoryException(
      "Failed to fetch swap history after $maxRetries attempts.",
      0,
    );
  }
}


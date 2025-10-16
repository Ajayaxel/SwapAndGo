// repository/subscription_plan_repository.dart
import 'dart:async';
import 'dart:io';
import 'package:swap_app/model/subscription_plan_model.dart';
import 'package:swap_app/services/subscription_plan_service.dart';

class SubscriptionPlanRepository {
  final SubscriptionPlanService _service = SubscriptionPlanService();

  /// Fetch subscription plans with retry logic
  Future<SubscriptionPlansResponse> fetchSubscriptionPlans() async {
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check network connectivity first
        await _service.checkNetworkConnectivity();
        
        // Fetch subscription plans
        final response = await _service.fetchSubscriptionPlans();
        
        return response;
      } on SubscriptionPlanException {
        // Don't retry on authentication or permission errors
        rethrow;
      } on TimeoutException {
        print('❌ Request timeout (Attempt ${retryCount + 1}/$maxRetries)');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SubscriptionPlanException("Request timeout. Please try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on SocketException {
        print('❌ Network error (Attempt ${retryCount + 1}/$maxRetries)');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SubscriptionPlanException(
            "No internet connection. Please check your network and try again.",
            0,
          );
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on HttpException catch (e) {
        print('❌ HTTP Exception (Attempt ${retryCount + 1}/$maxRetries): $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SubscriptionPlanException("Network error: ${e.message}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on FormatException catch (e) {
        print('❌ Format Exception: $e');
        // Don't retry on format errors
        throw SubscriptionPlanException("Invalid response format from server.", 0);
      } catch (e) {
        print('❌ Unexpected error (Attempt ${retryCount + 1}/$maxRetries): $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw SubscriptionPlanException(
            "An unexpected error occurred: ${e.toString()}",
            0,
          );
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    
    throw SubscriptionPlanException(
      "Failed to fetch subscription plans after $maxRetries attempts.",
      0,
    );
  }
}


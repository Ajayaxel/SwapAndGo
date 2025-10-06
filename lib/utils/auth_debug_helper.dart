// auth_debug_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/services/storage_helper.dart';

class AuthDebugHelper {
  /// Debug method to check current authentication status
  static Future<void> debugAuthStatus(BuildContext context) async {
    print('🔍 DEBUG: Checking authentication status...');
    
    // Check stored token
    final token = await StorageHelper.getString('auth_token');
    final userData = await StorageHelper.getString('user_data');
    
    print('🔍 DEBUG: Token exists: ${token != null}');
    print('🔍 DEBUG: User data exists: ${userData != null}');
    
    // Check current auth state
    final authState = context.read<AuthBloc>().state;
    print('🔍 DEBUG: Current auth state: ${authState.runtimeType}');
    
    if (authState is AuthSuccess) {
      print('🔍 DEBUG: User is authenticated - Customer: ${authState.customer.email}');
    } else if (authState is AuthUnauthenticated) {
      print('🔍 DEBUG: User is unauthenticated');
    } else if (authState is AuthError) {
      print('🔍 DEBUG: Authentication error: ${authState.message}');
    }
  }

  /// Simulate unauthenticated state for testing
  static Future<void> simulateUnauthenticated(BuildContext context) async {
    print('🔍 DEBUG: Simulating unauthenticated state...');
    
    // Clear stored data
    await StorageHelper.remove('auth_token');
    await StorageHelper.remove('user_data');
    
    // Trigger logout in auth bloc
    context.read<AuthBloc>().add(LogoutEvent());
    
    print('🔍 DEBUG: Cleared authentication data and triggered logout');
  }

  /// Check if authentication flow is working correctly
  static Future<bool> isAuthFlowWorking(BuildContext context) async {
    try {
      final authState = context.read<AuthBloc>().state;
      
      if (authState is AuthUnauthenticated) {
        print('✅ DEBUG: Auth flow working - User is unauthenticated');
        return true;
      } else if (authState is AuthSuccess) {
        print('✅ DEBUG: Auth flow working - User is authenticated');
        return true;
      } else {
        print('❌ DEBUG: Auth flow issue - Unexpected state: ${authState.runtimeType}');
        return false;
      }
    } catch (e) {
      print('❌ DEBUG: Auth flow error: $e');
      return false;
    }
  }
}

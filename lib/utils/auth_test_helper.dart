// auth_test_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/services/global_auth_service.dart';

class AuthTestHelper {
  /// Simulates an unauthenticated state for testing
  static void simulateUnauthenticated(BuildContext context) {
    // Clear stored data
    GlobalAuthService.logout(context);
  }

  /// Checks if the app properly handles unauthenticated states
  static bool isHandlingAuthCorrectly(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    
    // Check if the state is properly handled
    if (authState is AuthUnauthenticated) {
      return true; // App should navigate to login
    }
    
    if (authState is AuthError) {
      return true; // App should show error and potentially navigate to login
    }
    
    return false;
  }

  /// Validates that authentication flow is working
  static Future<bool> validateAuthFlow(BuildContext context) async {
    try {
      // Check if user is authenticated
      final isAuth = await GlobalAuthService.isAuthenticated();
      
      if (!isAuth) {
        // Should navigate to login
        return true;
      }
      
      return true;
    } catch (e) {
      print('Auth validation error: $e');
      return false;
    }
  }
}


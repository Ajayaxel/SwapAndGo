// global_auth_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/presentation/login/login_screen.dart';
import 'package:swap_app/services/storage_helper.dart';

class GlobalAuthService {
  /// Handles 401 unauthorized responses globally
  static void handleUnauthorized(BuildContext context) {
    // Clear stored authentication data
    StorageHelper.remove('auth_token');
    StorageHelper.remove('user_data');
    
    // Trigger logout in auth bloc
    context.read<AuthBloc>().add(LogoutEvent());
    
    // Navigate to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
    
    // Show message to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Checks if user is authenticated by verifying stored token
  static Future<bool> isAuthenticated() async {
    try {
      final token = await StorageHelper.getString('auth_token');
      final userData = await StorageHelper.getString('user_data');
      return token != null && userData != null;
    } catch (e) {
      return false;
    }
  }

  /// Gets the current authentication token
  static Future<String?> getAuthToken() async {
    try {
      return await StorageHelper.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  /// Logs out the user and clears all stored data
  static Future<void> logout(BuildContext context) async {
    try {
      await StorageHelper.remove('auth_token');
      await StorageHelper.remove('user_data');
      
      // Trigger logout in auth bloc
      context.read<AuthBloc>().add(LogoutEvent());
      
      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
    }
  }
}

// auth_handler.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/presentation/login/login_screen.dart';
import 'package:swap_app/services/storage_helper.dart';

class AuthHandler {
  /// Handles authentication errors and automatically navigates to login
  /// when the user is unauthenticated (401 status code)
  static void handleAuthError(BuildContext context, int? statusCode, String message) {
    if (statusCode == 401) {
      // User is unauthenticated, logout and navigate to login
      context.read<AuthBloc>().add(LogoutEvent());
      
      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      
      // Show message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Show other error messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Checks if the current state is unauthenticated and navigates to login
  static void checkAuthAndNavigate(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated || state is AuthError) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Wrapper for API calls that automatically handles authentication
  static Future<http.Response> authenticatedRequest(
    String url, {
    Map<String, String>? headers,
    Object? body,
    String method = 'GET',
  }) async {
    final token = await StorageHelper.getString('auth_token');
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: requestHeaders);
      case 'POST':
        return await http.post(Uri.parse(url), headers: requestHeaders, body: body);
      case 'PUT':
        return await http.put(Uri.parse(url), headers: requestHeaders, body: body);
      case 'DELETE':
        return await http.delete(Uri.parse(url), headers: requestHeaders);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }
}

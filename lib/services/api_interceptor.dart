// api_interceptor.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swap_app/services/storage_helper.dart';
import 'package:swap_app/services/global_auth_service.dart';

class ApiInterceptor {
  static const String baseUrl = 'https://onecharge.io';

  /// Makes an authenticated GET request
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    BuildContext? context,
  }) async {
    final token = await StorageHelper.getString('auth_token');
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: requestHeaders,
    );

    // Handle authentication errors
    if (response.statusCode == 401 && context != null) {
      GlobalAuthService.handleUnauthorized(context);
    }

    return response;
  }

  /// Makes an authenticated POST request
  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    BuildContext? context,
  }) async {
    final token = await StorageHelper.getString('auth_token');
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: requestHeaders,
      body: body,
    );

    // Handle authentication errors
    if (response.statusCode == 401 && context != null) {
      GlobalAuthService.handleUnauthorized(context);
    }

    return response;
  }

  /// Makes an authenticated PUT request
  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    BuildContext? context,
  }) async {
    final token = await StorageHelper.getString('auth_token');
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: requestHeaders,
      body: body,
    );

    // Handle authentication errors
    if (response.statusCode == 401 && context != null) {
      GlobalAuthService.handleUnauthorized(context);
    }

    return response;
  }

  /// Makes an authenticated DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    BuildContext? context,
  }) async {
    final token = await StorageHelper.getString('auth_token');
    
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: requestHeaders,
    );

    // Handle authentication errors
    if (response.statusCode == 401 && context != null) {
      GlobalAuthService.handleUnauthorized(context);
    }

    return response;
  }
}

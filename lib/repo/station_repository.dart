// repository/station_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/station_model.dart';
import 'package:swap_app/services/storage_helper.dart';
import 'package:swap_app/services/global_auth_service.dart';

class StationRepository {
  final String baseUrl = "https://onecharge.io/api/stations";
  static const Duration _timeout = Duration(seconds: 60);

  Future<List<Station>> fetchStations({
    String? search,
    String? status,
    String? city,
    String? is24x7,
    String? isActive,
    int perPage = 15,
  }) async {
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check network connectivity
        await _checkNetworkConnectivity();
        
        // Get authentication token
        final token = await StorageHelper.getString('auth_token');
        
        final uri = Uri.parse(baseUrl).replace(
          queryParameters: {
            'search': search ?? '',
            'status': status ?? '',
            'city': city ?? '',
            'is_24_7': is24x7 ?? '',
            'is_active': isActive ?? '',
            'per_page': perPage.toString(),
          },
        );

        print('🔍 Fetching stations from: $uri (Attempt ${retryCount + 1}/$maxRetries)');
        
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(_timeout);

        print('📡 Station API Response: ${response.statusCode}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          
          // Check if the API response is successful
          if (jsonData['success'] == true && jsonData['data'] != null) {
            print('🔍 Debug: jsonData structure: ${jsonData.runtimeType}');
            print('🔍 Debug: jsonData[\'data\'] structure: ${jsonData['data'].runtimeType}');
            print('🔍 Debug: jsonData[\'data\'][\'data\'] structure: ${jsonData['data']['data'].runtimeType}');
            
            final data = jsonData['data']['data'] as List<dynamic>;
            print('🔍 Debug: data length: ${data.length}');
            print('🔍 Debug: first station type: ${data.isNotEmpty ? data[0].runtimeType : 'empty'}');
            
            final stations = <Station>[];
            for (int i = 0; i < data.length; i++) {
              try {
                print('🔍 Debug: processing station $i: ${data[i].runtimeType}');
                if (data[i] is Map<String, dynamic>) {
                  stations.add(Station.fromJson(data[i] as Map<String, dynamic>));
                } else {
                  print('❌ Station $i is not a Map: ${data[i].runtimeType}');
                  print('❌ Station $i data: ${data[i]}');
                }
              } catch (e) {
                print('❌ Error parsing station $i: $e');
                print('❌ Station $i data: ${data[i]}');
                // Continue processing other stations instead of failing completely
                continue;
              }
            }
            print('✅ Successfully loaded ${stations.length} stations');
            return stations;
          } else {
            final errorMessage = jsonData['message'] ?? "Failed to load stations";
            print('❌ API Error: $errorMessage');
            throw StationApiException(errorMessage, response.statusCode);
          }
        } else if (response.statusCode == 401) {
          print('❌ Authentication failed - Token may be expired');
          throw StationApiException("Authentication failed. Please login again.", response.statusCode);
        } else if (response.statusCode == 403) {
          print('❌ Access forbidden');
          throw StationApiException("Access denied. You don't have permission to view stations.", response.statusCode);
        } else if (response.statusCode == 404) {
          print('❌ Stations not found');
          throw StationApiException("No stations found.", response.statusCode);
        } else if (response.statusCode >= 500) {
          print('❌ Server error: ${response.statusCode}');
          throw StationApiException("Server error. Please try again later.", response.statusCode);
        } else {
          print('❌ HTTP Error: ${response.statusCode}');
          throw StationApiException("Failed to load stations. Status: ${response.statusCode}", response.statusCode);
        }
      } on TimeoutException {
        print('❌ Request timeout');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw StationApiException("Request timeout. Please try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on SocketException {
        print('❌ Network error: No internet connection');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw StationApiException("No internet connection. Please check your network and try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on HttpException catch (e) {
        print('❌ HTTP Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw StationApiException("Network error: ${e.message}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on FormatException catch (e) {
        print('❌ Format Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw StationApiException("Invalid response format from server.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } catch (e) {
        print('❌ Unexpected error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw StationApiException("An unexpected error occurred: ${e.toString()}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    
    throw StationApiException("Failed to fetch stations after $maxRetries attempts.", 0);
  }

  /// Fetch station by ID
  Future<Station> fetchStationById(String id) async {
    try {
      // Check network connectivity
      await _checkNetworkConnectivity();
      
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      
      final uri = Uri.parse("$baseUrl/$id");
      
      print('🔍 Fetching station by ID: $id from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📡 Station API Response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final station = Station.fromJson(jsonData['data'] as Map<String, dynamic>);
          print('✅ Successfully loaded station: ${station.name}');
          return station;
        } else {
          final errorMessage = jsonData['message'] ?? "Failed to load station";
          print('❌ API Error: $errorMessage');
          throw StationApiException(errorMessage, response.statusCode);
        }
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired');
        throw StationApiException("Authentication failed. Please login again.", response.statusCode);
      } else if (response.statusCode == 404) {
        print('❌ Station not found');
        throw StationApiException("Station not found.", response.statusCode);
      } else if (response.statusCode >= 500) {
        print('❌ Server error: ${response.statusCode}');
        throw StationApiException("Server error. Please try again later.", response.statusCode);
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw StationApiException("Failed to load station. Status: ${response.statusCode}", response.statusCode);
      }
    } on TimeoutException {
      print('❌ Request timeout');
      throw StationApiException("Request timeout. Please try again.", 0);
    } on SocketException {
      print('❌ Network error: No internet connection');
      throw StationApiException("No internet connection. Please check your network and try again.", 0);
    } on HttpException catch (e) {
      print('❌ HTTP Exception: $e');
      throw StationApiException("Network error: ${e.message}", 0);
    } on FormatException catch (e) {
      print('❌ Format Exception: $e');
      throw StationApiException("Invalid response format from server.", 0);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw StationApiException("An unexpected error occurred: ${e.toString()}", 0);
    }
  }

  /// Check network connectivity
  Future<void> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw StationApiException("No internet connection available.", 0);
      }
    } on SocketException {
      throw StationApiException("No internet connection. Please check your network.", 0);
    }
  }
}

/// Custom exception class for station API errors
class StationApiException implements Exception {
  final String message;
  final int statusCode;
  
  const StationApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'StationApiException: $message (Status: $statusCode)';
}

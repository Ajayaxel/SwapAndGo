// address_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/address_models.dart';
import 'package:swap_app/services/storage_helper.dart';

class AddressRepository {
  final String baseUrl = "https://onecharge.io/api/customer/addresses";
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetch user addresses
  Future<List<Address>> fetchAddresses() async {
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check network connectivity
        await _checkNetworkConnectivity();
        
        // Get authentication token
        final token = await StorageHelper.getString('auth_token');
        
        if (token == null) {
          throw AddressApiException("Authentication required. Please login again.", 401);
        }

        print('🔍 Fetching addresses from: $baseUrl (Attempt ${retryCount + 1}/$maxRetries)');
        
        final response = await http.get(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(_timeout);

        print('📡 Address API Response: ${response.statusCode}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          
          // Check if the API response is successful
          if (jsonData['success'] == true && jsonData['data'] != null) {
            final addressResponse = AddressResponse.fromJson(jsonData);
            print('✅ Successfully loaded ${addressResponse.addresses.length} addresses');
            return addressResponse.addresses;
          } else {
            final errorMessage = jsonData['message'] ?? "Failed to load addresses";
            print('❌ API Error: $errorMessage');
            throw AddressApiException(errorMessage, response.statusCode);
          }
        } else if (response.statusCode == 401) {
          print('❌ Authentication failed - Token may be expired');
          throw AddressApiException("Authentication failed. Please login again.", response.statusCode);
        } else if (response.statusCode == 403) {
          print('❌ Access forbidden');
          throw AddressApiException("Access denied. You don't have permission to view addresses.", response.statusCode);
        } else if (response.statusCode == 404) {
          print('❌ Addresses not found');
          throw AddressApiException("No addresses found.", response.statusCode);
        } else if (response.statusCode >= 500) {
          print('❌ Server error: ${response.statusCode}');
          throw AddressApiException("Server error. Please try again later.", response.statusCode);
        } else {
          print('❌ HTTP Error: ${response.statusCode}');
          throw AddressApiException("Failed to load addresses. Status: ${response.statusCode}", response.statusCode);
        }
      } on TimeoutException {
        print('❌ Request timeout');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Request timeout. Please try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on SocketException {
        print('❌ Network error: No internet connection');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("No internet connection. Please check your network and try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on HttpException catch (e) {
        print('❌ HTTP Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Network error: ${e.message}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on FormatException catch (e) {
        print('❌ Format Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Invalid response format from server.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } catch (e) {
        print('❌ Unexpected error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("An unexpected error occurred: ${e.toString()}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    
    throw AddressApiException("Failed to fetch addresses after $maxRetries attempts.", 0);
  }

  /// Create a new address
  Future<Address> createAddress(CreateAddressRequest request) async {
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check network connectivity
        await _checkNetworkConnectivity();
        
        // Get authentication token
        final token = await StorageHelper.getString('auth_token');
        
        if (token == null) {
          throw AddressApiException("Authentication required. Please login again.", 401);
        }

        print('🔍 Creating address: ${request.toJson()} (Attempt ${retryCount + 1}/$maxRetries)');
        
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(request.toJson()),
        ).timeout(_timeout);

        print('📡 Create Address API Response: ${response.statusCode}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonData = json.decode(response.body);
          
          // Check if the API response is successful
          if (jsonData['success'] == true && jsonData['data'] != null) {
            final createResponse = CreateAddressResponse.fromJson(jsonData);
            if (createResponse.address != null) {
              print('✅ Successfully created address: ${createResponse.address!.id}');
              return createResponse.address!;
            } else {
              throw AddressApiException("Failed to create address: No address data returned", response.statusCode);
            }
          } else {
            final errorMessage = jsonData['message'] ?? "Failed to create address";
            print('❌ API Error: $errorMessage');
            throw AddressApiException(errorMessage, response.statusCode);
          }
        } else if (response.statusCode == 401) {
          print('❌ Authentication failed - Token may be expired');
          throw AddressApiException("Authentication failed. Please login again.", response.statusCode);
        } else if (response.statusCode == 403) {
          print('❌ Access forbidden');
          throw AddressApiException("Access denied. You don't have permission to create addresses.", response.statusCode);
        } else if (response.statusCode == 422) {
          // Validation errors
          final jsonData = json.decode(response.body);
          final errorMessage = jsonData['message'] ?? "Validation failed";
          print('❌ Validation Error: $errorMessage');
          throw AddressApiException(errorMessage, response.statusCode);
        } else if (response.statusCode >= 500) {
          print('❌ Server error: ${response.statusCode}');
          throw AddressApiException("Server error. Please try again later.", response.statusCode);
        } else {
          print('❌ HTTP Error: ${response.statusCode}');
          throw AddressApiException("Failed to create address. Status: ${response.statusCode}", response.statusCode);
        }
      } on TimeoutException {
        print('❌ Request timeout');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Request timeout. Please try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on SocketException {
        print('❌ Network error: No internet connection');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("No internet connection. Please check your network and try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on HttpException catch (e) {
        print('❌ HTTP Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Network error: ${e.message}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on FormatException catch (e) {
        print('❌ Format Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Invalid response format from server.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } catch (e) {
        print('❌ Unexpected error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("An unexpected error occurred: ${e.toString()}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    
    throw AddressApiException("Failed to create address after $maxRetries attempts.", 0);
  }

  /// Update an address
  Future<Address> updateAddress(int addressId, UpdateAddressRequest request) async {
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check network connectivity
        await _checkNetworkConnectivity();
        
        // Get authentication token
        final token = await StorageHelper.getString('auth_token');
        
        if (token == null) {
          throw AddressApiException("Authentication required. Please login again.", 401);
        }

        final updateUrl = "$baseUrl/$addressId";
        print('🔍 Updating address ID: $addressId with data: ${request.toJson()} (Attempt ${retryCount + 1}/$maxRetries)');
        
        final response = await http.put(
          Uri.parse(updateUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(request.toJson()),
        ).timeout(_timeout);

        print('📡 Update Address API Response: ${response.statusCode}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          
          // Check if the API response is successful
          if (jsonData['success'] == true && jsonData['data'] != null) {
            final updateResponse = UpdateAddressResponse.fromJson(jsonData);
            if (updateResponse.address != null) {
              print('✅ Successfully updated address: ${updateResponse.address!.id}');
              return updateResponse.address!;
            } else {
              throw AddressApiException("Failed to update address: No address data returned", response.statusCode);
            }
          } else {
            final errorMessage = jsonData['message'] ?? "Failed to update address";
            print('❌ API Error: $errorMessage');
            throw AddressApiException(errorMessage, response.statusCode);
          }
        } else if (response.statusCode == 401) {
          print('❌ Authentication failed - Token may be expired');
          throw AddressApiException("Authentication failed. Please login again.", response.statusCode);
        } else if (response.statusCode == 403) {
          print('❌ Access forbidden');
          throw AddressApiException("Access denied. You don't have permission to update addresses.", response.statusCode);
        } else if (response.statusCode == 404) {
          print('❌ Address not found');
          throw AddressApiException("Address not found.", response.statusCode);
        } else if (response.statusCode == 422) {
          // Validation errors
          final jsonData = json.decode(response.body);
          final errorMessage = jsonData['message'] ?? "Validation failed";
          print('❌ Validation Error: $errorMessage');
          throw AddressApiException(errorMessage, response.statusCode);
        } else if (response.statusCode >= 500) {
          print('❌ Server error: ${response.statusCode}');
          throw AddressApiException("Server error. Please try again later.", response.statusCode);
        } else {
          print('❌ HTTP Error: ${response.statusCode}');
          throw AddressApiException("Failed to update address. Status: ${response.statusCode}", response.statusCode);
        }
      } on TimeoutException {
        print('❌ Request timeout');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Request timeout. Please try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on SocketException {
        print('❌ Network error: No internet connection');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("No internet connection. Please check your network and try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on HttpException catch (e) {
        print('❌ HTTP Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Network error: ${e.message}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on FormatException catch (e) {
        print('❌ Format Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Invalid response format from server.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } catch (e) {
        print('❌ Unexpected error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("An unexpected error occurred: ${e.toString()}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    
    throw AddressApiException("Failed to update address after $maxRetries attempts.", 0);
  }

  /// Delete an address
  Future<void> deleteAddress(int addressId) async {
    const int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        // Check network connectivity
        await _checkNetworkConnectivity();
        
        // Get authentication token
        final token = await StorageHelper.getString('auth_token');
        
        if (token == null) {
          throw AddressApiException("Authentication required. Please login again.", 401);
        }

        final deleteUrl = "$baseUrl/$addressId";
        print('🔍 Deleting address ID: $addressId from: $deleteUrl (Attempt ${retryCount + 1}/$maxRetries)');
        
        final response = await http.delete(
          Uri.parse(deleteUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(_timeout);

        print('📡 Delete Address API Response: ${response.statusCode}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          
          // Check if the API response is successful
          if (jsonData['success'] == true) {
            print('✅ Successfully deleted address: $addressId');
            return;
          } else {
            final errorMessage = jsonData['message'] ?? "Failed to delete address";
            print('❌ API Error: $errorMessage');
            throw AddressApiException(errorMessage, response.statusCode);
          }
        } else if (response.statusCode == 401) {
          print('❌ Authentication failed - Token may be expired');
          throw AddressApiException("Authentication failed. Please login again.", response.statusCode);
        } else if (response.statusCode == 403) {
          print('❌ Access forbidden');
          throw AddressApiException("Access denied. You don't have permission to delete addresses.", response.statusCode);
        } else if (response.statusCode == 404) {
          print('❌ Address not found');
          throw AddressApiException("Address not found.", response.statusCode);
        } else if (response.statusCode >= 500) {
          print('❌ Server error: ${response.statusCode}');
          throw AddressApiException("Server error. Please try again later.", response.statusCode);
        } else {
          print('❌ HTTP Error: ${response.statusCode}');
          throw AddressApiException("Failed to delete address. Status: ${response.statusCode}", response.statusCode);
        }
      } on TimeoutException {
        print('❌ Request timeout');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Request timeout. Please try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on SocketException {
        print('❌ Network error: No internet connection');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("No internet connection. Please check your network and try again.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on HttpException catch (e) {
        print('❌ HTTP Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Network error: ${e.message}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } on FormatException catch (e) {
        print('❌ Format Exception: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("Invalid response format from server.", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      } catch (e) {
        print('❌ Unexpected error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw AddressApiException("An unexpected error occurred: ${e.toString()}", 0);
        }
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
    
    throw AddressApiException("Failed to delete address after $maxRetries attempts.", 0);
  }

  /// Fetch countries from server (fallback to local list)
  Future<List<Country>> fetchCountries() async {
    // Since the countries API endpoint is not available, 
    // we'll always throw an exception to trigger the fallback
    throw AddressApiException("Countries endpoint not available.", 404);
  }

  /// Check network connectivity
  Future<void> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw AddressApiException("No internet connection available.", 0);
      }
    } on SocketException {
      throw AddressApiException("No internet connection. Please check your network.", 0);
    }
  }
}

/// Custom exception class for address API errors
class AddressApiException implements Exception {
  final String message;
  final int statusCode;
  
  const AddressApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'AddressApiException: $message (Status: $statusCode)';
}

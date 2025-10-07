// profile_image_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/profile_image_models.dart';
import 'package:swap_app/services/storage_helper.dart';

class ProfileImageRepository {
  static const String baseUrl = 'https://onecharge.io/api/customer/profile';
  static const Duration _timeout = Duration(seconds: 30);

  /// Upload profile image
  Future<ProfileImageUploadResponse> uploadProfileImage(File imageFile) async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      if (token == null) {
        throw ProfileImageException('Authentication token not found');
      }

      print('📸 Uploading profile image...');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-image'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          imageFile.path,
        ),
      );

      // Send request
      var streamedResponse = await request.send().timeout(_timeout);
      var response = await http.Response.fromStream(streamedResponse);

      print('📸 Profile image upload response: ${response.statusCode}');
      print('📸 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProfileImageUploadResponse.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        throw ProfileImageException(
          errorBody['message'] ?? 'Failed to upload profile image',
        );
      }
    } on ProfileImageException {
      rethrow;
    } catch (e) {
      print('❌ Profile image upload error: $e');
      throw ProfileImageException('Network error. Please check your connection.');
    }
  }

  /// Fetch customer profile (including profile image)
  Future<ProfileFetchResponse> fetchCustomerProfile() async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      if (token == null) {
        throw ProfileImageException('Authentication token not found');
      }

      print('📸 Fetching customer profile...');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📸 Profile fetch response: ${response.statusCode}');
      print('📸 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProfileFetchResponse.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        throw ProfileImageException(
          errorBody['message'] ?? 'Failed to fetch profile',
        );
      }
    } on ProfileImageException {
      rethrow;
    } catch (e) {
      print('❌ Profile fetch error: $e');
      throw ProfileImageException('Network error. Please check your connection.');
    }
  }

  /// Delete profile image
  Future<ProfileImageDeleteResponse> deleteProfileImage() async {
    try {
      // Get authentication token
      final token = await StorageHelper.getString('auth_token');
      if (token == null) {
        throw ProfileImageException('Authentication token not found');
      }

      print('📸 Deleting profile image...');

      final response = await http.delete(
        Uri.parse('$baseUrl/delete-image'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      print('📸 Profile image delete response: ${response.statusCode}');
      print('📸 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProfileImageDeleteResponse.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        throw ProfileImageException(
          errorBody['message'] ?? 'Failed to delete profile image',
        );
      }
    } on ProfileImageException {
      rethrow;
    } catch (e) {
      print('❌ Profile image delete error: $e');
      throw ProfileImageException('Network error. Please check your connection.');
    }
  }
}

/// Custom exception for profile image operations
class ProfileImageException implements Exception {
  final String message;
  ProfileImageException(this.message);

  @override
  String toString() => 'ProfileImageException: $message';
}

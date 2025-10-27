// permission_helper.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  /// Request camera permission for taking photos
  static Future<bool> requestCameraPermission() async {
    print('🔐 Requesting camera permission...');
    
    final status = await Permission.camera.request();
    print('📷 Camera permission status: $status');
    
    if (status == PermissionStatus.granted) {
      print('✅ Camera permission granted');
      return true;
    } else if (status == PermissionStatus.denied) {
      print('❌ Camera permission denied');
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('❌ Camera permission permanently denied');
      return false;
    }
    
    return false;
  }

  /// Request photo library permission for selecting images
  static Future<bool> requestPhotoLibraryPermission() async {
    print('🔐 Requesting photo library permission...');
    
    // Try photos permission first (Android 13+), fallback to storage
    Permission permission = Permission.photos;
    print('📱 Using photos permission');
    
    final status = await permission.request();
    print('📸 Photo library permission status: $status');
    
    if (status == PermissionStatus.granted) {
      print('✅ Photo library permission granted');
      return true;
    } else if (status == PermissionStatus.denied) {
      print('❌ Photo library permission denied');
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('❌ Photo library permission permanently denied');
      return false;
    }
    
    return false;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    print('📷 Camera permission check: $status');
    return status == PermissionStatus.granted;
  }

  /// Check if photo library permission is granted
  static Future<bool> isPhotoLibraryPermissionGranted() async {
    Permission permission = Permission.photos;
    
    final status = await permission.status;
    print('📸 Photo library permission check: $status');
    return status == PermissionStatus.granted;
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    print('🔐 Requesting location permission...');
    
    final status = await Permission.location.request();
    print('📍 Location permission status: $status');
    
    if (status == PermissionStatus.granted) {
      print('✅ Location permission granted');
      return true;
    } else if (status == PermissionStatus.denied) {
      print('❌ Location permission denied');
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('❌ Location permission permanently denied');
      return false;
    }
    
    return false;
  }

  /// Request fine location permission
  static Future<bool> requestFineLocationPermission() async {
    print('🔐 Requesting fine location permission...');
    
    final status = await Permission.locationWhenInUse.request();
    print('📍 Fine location permission status: $status');
    
    if (status == PermissionStatus.granted) {
      print('✅ Fine location permission granted');
      return true;
    } else if (status == PermissionStatus.denied) {
      print('❌ Fine location permission denied');
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('❌ Fine location permission permanently denied');
      return false;
    }
    
    return false;
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    print('📍 Location permission check: $status');
    return status == PermissionStatus.granted;
  }

  /// Check if fine location permission is granted
  static Future<bool> isFineLocationPermissionGranted() async {
    final status = await Permission.locationWhenInUse.status;
    print('📍 Fine location permission check: $status');
    return status == PermissionStatus.granted;
  }

  /// Request all required permissions for the app
  static Future<Map<String, bool>> requestAllPermissions() async {
    print('🔐 Requesting all app permissions...');
    
    Map<String, bool> results = {};
    
    // Request camera permission
    results['camera'] = await requestCameraPermission();
    
    // Request location permission
    results['location'] = await requestLocationPermission();
    
    // Request photo library permission
    results['photos'] = await requestPhotoLibraryPermission();
    
    print('📊 Permission results: $results');
    return results;
  }

  /// Show permission denied dialog
  static void showPermissionDeniedDialog(BuildContext context, String permissionType) {
    String message = '';
    switch (permissionType.toLowerCase()) {
      case 'camera':
        message = 'This app needs camera permission to scan QR codes and take photos. Please grant permission in your device settings.';
        break;
      case 'location':
        message = 'This app needs location permission to find nearby battery stations and provide navigation. Please grant permission in your device settings.';
        break;
      case 'photos':
        message = 'This app needs photo library permission to access your photos. Please grant permission in your device settings.';
        break;
      default:
        message = 'This app needs $permissionType permission to function properly. Please grant permission in your device settings.';
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Show permission explanation dialog
  static void showPermissionExplanationDialog(BuildContext context, String permissionType) {
    String message = '';
    switch (permissionType.toLowerCase()) {
      case 'camera':
        message = 'This app needs camera permission to scan QR codes and take photos for your profile.';
        break;
      case 'location':
        message = 'This app needs location permission to find nearby battery stations and provide navigation services.';
        break;
      case 'photos':
        message = 'This app needs photo library permission to let you select photos for your profile picture.';
        break;
      default:
        message = 'This app needs $permissionType permission to function properly.';
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // The permission request will be handled by the calling function
              },
              child: Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }
}

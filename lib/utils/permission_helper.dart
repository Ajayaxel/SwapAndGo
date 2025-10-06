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

  /// Show permission denied dialog
  static void showPermissionDeniedDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            'This app needs $permissionType permission to access your photos. '
            'Please grant permission in your device settings.',
          ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            'This app needs $permissionType permission to let you select photos for your profile picture.',
          ),
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

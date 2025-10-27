import 'package:flutter/material.dart';
import 'package:swap_app/utils/permission_helper.dart';

class PermissionInitializer extends StatefulWidget {
  final Widget child;
  
  const PermissionInitializer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PermissionInitializer> createState() => _PermissionInitializerState();
}

class _PermissionInitializerState extends State<PermissionInitializer> {
  bool _permissionsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    try {
      // Check if permissions are already granted
      final cameraGranted = await PermissionHelper.isCameraPermissionGranted();
      final locationGranted = await PermissionHelper.isLocationPermissionGranted();
      final photosGranted = await PermissionHelper.isPhotoLibraryPermissionGranted();

      print('🔐 Initial permission status:');
      print('📷 Camera: $cameraGranted');
      print('📍 Location: $locationGranted');
      print('📸 Photos: $photosGranted');

      setState(() {
        _permissionsInitialized = true;
      });
    } catch (e) {
      print('❌ Error initializing permissions: $e');
      setState(() {
        _permissionsInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.child;
  }
}

/// A widget that requests permissions when needed
class PermissionRequestWidget extends StatelessWidget {
  final String permissionType;
  final Widget child;
  final Widget? fallback;

  const PermissionRequestWidget({
    Key? key,
    required this.permissionType,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return child;
        } else {
          return fallback ?? _buildPermissionRequest(context);
        }
      },
    );
  }

  Future<bool> _checkPermission() async {
    switch (permissionType.toLowerCase()) {
      case 'camera':
        return await PermissionHelper.isCameraPermissionGranted();
      case 'location':
        return await PermissionHelper.isLocationPermissionGranted();
      case 'photos':
        return await PermissionHelper.isPhotoLibraryPermissionGranted();
      default:
        return false;
    }
  }

  Widget _buildPermissionRequest(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getPermissionIcon(),
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Permission Required',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _getPermissionMessage(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _requestPermission(context),
            child: Text('Grant ${permissionType.toUpperCase()} Permission'),
          ),
        ],
      ),
    );
  }

  IconData _getPermissionIcon() {
    switch (permissionType.toLowerCase()) {
      case 'camera':
        return Icons.camera_alt;
      case 'location':
        return Icons.location_on;
      case 'photos':
        return Icons.photo_library;
      default:
        return Icons.security;
    }
  }

  String _getPermissionMessage() {
    switch (permissionType.toLowerCase()) {
      case 'camera':
        return 'This app needs camera permission to scan QR codes and take photos.';
      case 'location':
        return 'This app needs location permission to find nearby battery stations.';
      case 'photos':
        return 'This app needs photo library permission to access your photos.';
      default:
        return 'This app needs permission to function properly.';
    }
  }

  Future<void> _requestPermission(BuildContext context) async {
    bool granted = false;
    
    switch (permissionType.toLowerCase()) {
      case 'camera':
        granted = await PermissionHelper.requestCameraPermission();
        break;
      case 'location':
        granted = await PermissionHelper.requestLocationPermission();
        break;
      case 'photos':
        granted = await PermissionHelper.requestPhotoLibraryPermission();
        break;
    }

    if (!granted) {
      PermissionHelper.showPermissionDeniedDialog(context, permissionType);
    }
  }
}

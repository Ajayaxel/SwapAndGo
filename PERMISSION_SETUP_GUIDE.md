# Android Location and Camera Permissions Setup

## Overview
This guide explains the Android location and camera permissions that have been added to your SwapAndGo Flutter app.

## Permissions Added

### Android Manifest Permissions (`android/app/src/main/AndroidManifest.xml`)
- **Location Permissions:**
  - `ACCESS_FINE_LOCATION` - For precise location access
  - `ACCESS_COARSE_LOCATION` - For approximate location access
  - `ACCESS_BACKGROUND_LOCATION` - For location access when app is in background

- **Camera Permissions:**
  - `CAMERA` - For camera access (QR scanning, photo capture)

- **Storage Permissions:**
  - `READ_EXTERNAL_STORAGE` - For reading files from storage
  - `WRITE_EXTERNAL_STORAGE` - For writing files to storage
  - `READ_MEDIA_IMAGES` - For accessing images (Android 13+)

- **Camera Features:**
  - `android.hardware.camera` - Declares camera hardware requirement (optional)
  - `android.hardware.camera.autofocus` - Declares autofocus capability (optional)

## Permission Helper Utility

### Location: `lib/utils/permission_helper.dart`
Enhanced with location permission methods:

```dart
// Check location permissions
await PermissionHelper.isLocationPermissionGranted();
await PermissionHelper.isFineLocationPermissionGranted();

// Request location permissions
await PermissionHelper.requestLocationPermission();
await PermissionHelper.requestFineLocationPermission();

// Request all permissions at once
Map<String, bool> results = await PermissionHelper.requestAllPermissions();
```

### Camera Permissions
```dart
// Check camera permission
await PermissionHelper.isCameraPermissionGranted();

// Request camera permission
await PermissionHelper.requestCameraPermission();
```

## Usage Examples

### 1. Basic Permission Check
```dart
import 'package:swap_app/utils/permission_helper.dart';

// Check if camera permission is granted
bool hasCameraPermission = await PermissionHelper.isCameraPermissionGranted();

// Check if location permission is granted
bool hasLocationPermission = await PermissionHelper.isLocationPermissionGranted();
```

### 2. Request Permissions
```dart
// Request camera permission
bool cameraGranted = await PermissionHelper.requestCameraPermission();

// Request location permission
bool locationGranted = await PermissionHelper.requestLocationPermission();

// Request all permissions
Map<String, bool> results = await PermissionHelper.requestAllPermissions();
```

### 3. Handle Permission Denied
```dart
if (!cameraGranted) {
  PermissionHelper.showPermissionDeniedDialog(context, 'camera');
}
```

### 4. Using Permission Widgets
```dart
import 'package:swap_app/widgets/permission_initializer.dart';

// Wrap your app with permission initializer
PermissionInitializer(
  child: YourApp(),
)

// Use permission request widget for specific features
PermissionRequestWidget(
  permissionType: 'camera',
  child: QRScannerWidget(),
  fallback: PermissionDeniedWidget(),
)
```

## Integration Examples

### QR Scanner Screen
The QR scanner screen now includes:
- Automatic camera permission checking
- Permission request flow
- User-friendly error messages
- Retry mechanism for denied permissions

### Location Services
For location-based features:
```dart
// Before using location services
bool hasLocation = await PermissionHelper.isLocationPermissionGranted();
if (!hasLocation) {
  bool granted = await PermissionHelper.requestLocationPermission();
  if (!granted) {
    // Handle permission denied
    PermissionHelper.showPermissionDeniedDialog(context, 'location');
    return;
  }
}
// Proceed with location services
```

## Best Practices

1. **Always check permissions before using features**
2. **Provide clear explanations for why permissions are needed**
3. **Handle permission denied gracefully**
4. **Offer settings redirect for permanently denied permissions**
5. **Test on different Android versions (API 23+ for runtime permissions)**

## Testing

To test permissions:
1. Install the app on a device
2. Try to use camera/QR scanner features
3. Try to use location-based features
4. Test permission denial scenarios
5. Test permission re-granting from settings

## Troubleshooting

### Common Issues:
1. **Permission not requested**: Ensure you're calling the permission request methods
2. **Permission denied permanently**: Use `openAppSettings()` to redirect to settings
3. **Location not working**: Check if location services are enabled on device
4. **Camera not working**: Check if camera hardware is available

### Debug Logs:
The permission helper includes debug logs. Check console for:
- `🔐 Requesting [permission] permission...`
- `✅ [Permission] permission granted`
- `❌ [Permission] permission denied`

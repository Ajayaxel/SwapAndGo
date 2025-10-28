# Waze Map Integration

This document describes the integration of Waze map functionality in the SwapAndGo app, providing users with multiple navigation options while maintaining existing functionality.

## Overview

The Waze integration adds a map choice modal that allows users to select from three navigation options:
1. **Current Map** - Uses the existing in-app Google Maps navigation
2. **Apple Maps** - Opens directions in the Apple Maps app
3. **Waze** - Opens directions in the Waze app

## Folder Structure

```
lib/
├── presentation/
│   └── map_choice/
│       └── map_choice_modal.dart          # Map choice modal widget
└── services/
    └── map_services/
        ├── waze_service.dart              # Waze integration service
        └── apple_maps_service.dart        # Apple Maps integration service
```

## Features

### Map Choice Modal (`map_choice_modal.dart`)

A beautiful modal that presents three navigation options with:
- Clean, modern UI design
- Platform-appropriate icons and colors
- Clear descriptions for each option
- Smooth animations and transitions

**Key Features:**
- Responsive design that adapts to different screen sizes
- Consistent styling with the app's design language
- Easy-to-understand option descriptions
- Callback system for handling user selections

### Waze Service (`waze_service.dart`)

Handles all Waze-related functionality:

**Methods:**
- `openInWaze(LatLng destination, String destinationName)` - Opens Waze with coordinates
- `openInWazeWithSearch(String searchQuery)` - Opens Waze with search query
- `isWazeInstalled()` - Checks if Waze app is installed

**Features:**
- Automatic fallback to web version if app is not installed
- Error handling and logging
- Support for both coordinate-based and search-based navigation

### Apple Maps Service (`apple_maps_service.dart`)

Handles Apple Maps integration:

**Methods:**
- `openInAppleMaps(LatLng destination, String destinationName)` - Opens Apple Maps with coordinates
- `openInAppleMapsWithSearch(String searchQuery)` - Opens Apple Maps with search query
- `isAppleMapsAvailable()` - Checks if Apple Maps is available (iOS only)

**Features:**
- Platform-specific URL handling (iOS vs Android)
- Web fallback for Android devices
- Cross-platform compatibility

## Integration Points

### Station Screen Integration

The map choice modal is integrated into the station screen at two key points:

1. **Station Modal** - When viewing station details
2. **Station Cards** - In the station list

Both locations now show the map choice modal instead of directly starting navigation.

### Code Changes

**Modified Files:**
- `lib/presentation/station/station_screen.dart` - Added map choice modal integration
- `pubspec.yaml` - Added `url_launcher` dependency

**New Methods Added:**
- `_showMapChoiceModal(Station station)` - Shows the map choice modal

## Usage

### For Users

1. **Tap Directions Button** - On any station card or in station details
2. **Choose Navigation App** - Select from Current Map, Apple Maps, or Waze
3. **Navigate** - The selected app will open with directions to the station

### For Developers

**Adding Map Choice to New Screens:**

```dart
import '../map_choice/map_choice_modal.dart';

// Show map choice modal
void _showMapChoiceModal(Station station) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MapChoiceModal(
      destination: station.position,
      destinationName: station.name,
      onCurrentMapSelected: () {
        // Handle current map selection
        // Your existing navigation logic here
      },
    ),
  );
}
```

**Using Waze Service Directly:**

```dart
import '../../services/map_services/waze_service.dart';

// Open Waze with coordinates
await WazeService.openInWaze(destination, "Station Name");

// Open Waze with search query
await WazeService.openInWazeWithSearch("Station Name, City");
```

## Dependencies

**Added Dependencies:**
- `url_launcher: ^6.2.2` - For opening external map apps

**Existing Dependencies Used:**
- `google_maps_flutter` - For LatLng coordinates
- `flutter/material.dart` - For UI components

## Platform Support

### iOS
- ✅ Apple Maps app integration
- ✅ Waze app integration
- ✅ Web fallback for both

### Android
- ✅ Waze app integration
- ✅ Apple Maps web version
- ✅ Web fallback for Waze

## Error Handling

The integration includes comprehensive error handling:

- **App Not Installed** - Automatically falls back to web version
- **Network Issues** - Shows appropriate error messages
- **Permission Issues** - Handles gracefully with logging
- **Invalid Coordinates** - Validates before attempting to open apps

## Testing

### Manual Testing Checklist

- [ ] Map choice modal appears when tapping directions
- [ ] Current map option works (existing functionality)
- [ ] Apple Maps opens correctly on iOS
- [ ] Apple Maps web version opens on Android
- [ ] Waze opens correctly when installed
- [ ] Waze web version opens when app not installed
- [ ] Error handling works for network issues
- [ ] Modal dismisses correctly after selection

### Test Scenarios

1. **With Waze Installed** - Should open Waze app directly
2. **Without Waze** - Should open web version
3. **No Internet** - Should show appropriate error
4. **Invalid Coordinates** - Should handle gracefully

## Future Enhancements

Potential improvements for future versions:

1. **Google Maps Integration** - Add Google Maps app option
2. **User Preferences** - Remember user's preferred map app
3. **Custom Icons** - Use actual app icons instead of generic ones
4. **Analytics** - Track which map apps users prefer
5. **Offline Support** - Better handling of offline scenarios

## Maintenance

### Code Maintenance

- **Service Classes** - Keep URL schemes updated as apps change
- **Error Messages** - Update user-facing messages as needed
- **Dependencies** - Keep url_launcher updated
- **Platform Support** - Test on new OS versions

### URL Scheme Updates

If map apps change their URL schemes, update the services:
- Waze: `waze://` and `https://waze.com/ul`
- Apple Maps: `maps://` and `https://maps.apple.com`

## Troubleshooting

### Common Issues

1. **Waze not opening** - Check if app is installed, try web version
2. **Apple Maps not working on Android** - Expected behavior, uses web version
3. **Modal not appearing** - Check import statements and context
4. **Coordinates invalid** - Verify LatLng values are valid

### Debug Information

Enable debug logging to see detailed error information:
```dart
debugPrint('Error opening Waze: $e');
```

## Conclusion

The Waze map integration provides users with flexible navigation options while maintaining the existing app functionality. The modular design makes it easy to extend with additional map services in the future.

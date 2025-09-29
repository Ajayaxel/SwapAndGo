# SwapAndGo Modular Architecture

This document explains the new modular architecture implemented for the SwapAndGo home screen functionality.

## 📁 File Structure

```
lib/
├── models/
│   └── navigation_models.dart          # Data models
├── services/
│   ├── map_service.dart               # Map-related functionality
│   └── station_service.dart           # Station-related operations
├── controllers/
│   └── navigation_controller.dart      # Navigation state management
├── widgets/
│   ├── reusable_map_widget.dart       # Reusable map components
│   ├── search_widget.dart             # Search functionality
│   └── station_bottom_sheet.dart      # Station bottom sheet UI
└── presentation/home/
    ├── home_page.dart                 # Original implementation
    └── home_page_modular.dart         # New modular implementation
```

## 🏗️ Architecture Components

### 1. Models (`models/navigation_models.dart`)
- **NavStep**: Navigation step for turn-by-turn directions
- **DestinationStation**: Station data model with position, type, slots
- **RouteInfo**: Complete route information with polylines and steps

### 2. Services

#### MapService (`services/map_service.dart`)
- **Purpose**: Handle all map-related operations
- **Features**:
  - Custom marker loading
  - Location services
  - Route calculation using Google Directions API
  - Distance and bearing calculations
  - Polyline decoding
  - Camera bounds creation

#### StationService (`services/station_service.dart`)
- **Purpose**: Manage station-related operations
- **Features**:
  - Generate dummy stations within radius
  - Create station markers
  - Find nearest stations
  - Filter stations by criteria
  - Simulate booking functionality

### 3. Controllers

#### NavigationController (`controllers/navigation_controller.dart`)
- **Purpose**: Centralized state management for navigation
- **Features**:
  - Location tracking
  - Route management
  - Navigation state (active/inactive)
  - Marker and polyline management
  - Real-time location updates during navigation

### 4. Widgets

#### ReusableMapWidget (`widgets/reusable_map_widget.dart`)
- **Purpose**: Reusable Google Map component
- **Features**:
  - Configurable map settings
  - NavigationMapWidget for turn-by-turn navigation
  - Camera control methods

#### SearchWidget (`widgets/search_widget.dart`)
- **Purpose**: Reusable search functionality
- **Features**:
  - Google Places autocomplete
  - Debounced search
  - Positioned variant for map overlays

#### StationBottomSheet (`widgets/station_bottom_sheet.dart`)
- **Purpose**: Station information and actions
- **Features**:
  - Station details display
  - "See Routes" and "Book" buttons
  - Static show method for easy usage

## 🔄 How to Use

### Basic Implementation

```dart
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late NavigationController _navigationController;
  final StationService _stationService = StationService();

  @override
  void initState() {
    super.initState();
    _navigationController = NavigationController();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _navigationController.initialize();
    // Generate and add stations
    final stations = _stationService.generateDummyStations(
      _navigationController.currentPosition!,
    );
    final markers = _stationService.createStationMarkers(
      stations,
      _onStationTap,
    );
    _navigationController.addStationMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _navigationController,
      builder: (context, child) {
        return ReusableMapWidget(
          initialPosition: _navigationController.currentPosition,
          markers: _navigationController.markers,
          polylines: _navigationController.polylines,
        );
      },
    );
  }
}
```

### Station Interaction

```dart
void _onStationTap(DestinationStation station) {
  // Set destination and show route
  _navigationController.setDestination(station.position);
  
  // Show bottom sheet
  StationBottomSheet.show(
    context,
    station: station,
    onSeeRoutes: () {
      _navigationController.startNavigation();
    },
    onBook: () {
      _bookStation(station);
    },
  );
}
```

## 🎯 Benefits

### 1. **Maintainability**
- Separated concerns into logical modules
- Easy to locate and modify specific functionality
- Clear dependencies between components

### 2. **Reusability**
- Map widget can be used in other screens
- Search functionality is portable
- Services can be used across the app

### 3. **Testability**
- Services can be easily unit tested
- Controllers can be tested independently
- Widgets can be tested in isolation

### 4. **Scalability**
- Easy to add new features
- Simple to extend existing functionality
- Clear patterns for future development

### 5. **Code Organization**
- Logical file structure
- Clear separation of UI and business logic
- Consistent naming conventions

## 🚀 Migration Guide

To migrate from the original `home_page.dart` to the modular version:

1. **Replace imports**: Update to use new modular components
2. **Initialize controller**: Use `NavigationController` instead of direct state management
3. **Use widgets**: Replace custom UI code with reusable widgets
4. **Update state management**: Use `ListenableBuilder` with `NavigationController`

## 🔧 Customization

### Adding New Station Types
```dart
// In station_service.dart
List<String> getStationTypes() {
  return ['Fast Charge', 'Standard', 'Super Fast', 'Solar'];
}
```

### Custom Map Styles
```dart
// In reusable_map_widget.dart
GoogleMap(
  // ... other properties
  style: _mapStyle, // Add custom map style
)
```

### Extended Navigation Features
```dart
// In navigation_controller.dart
void addWaypoint(LatLng waypoint) {
  // Add waypoint functionality
}
```

This modular architecture provides a solid foundation for maintaining and extending the SwapAndGo application while keeping the code organized and reusable.

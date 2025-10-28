# Map Choice Integration

This folder contains the map choice functionality that allows users to select from different navigation apps.

## Files

- `map_choice_modal.dart` - The main modal widget for choosing navigation apps

## Usage Example

```dart
import '../map_choice/map_choice_modal.dart';

// Show the map choice modal
void showMapOptions(Station station) {
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
        _startInAppNavigation(station);
      },
    ),
  );
}
```

## Integration

The modal is already integrated into:
- Station screen station cards
- Station details modal

No additional setup required - just tap any "Directions" button to see the map choice options.

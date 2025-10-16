# Station Search Implementation - API-Based Location Search

## Overview
Replaced Google Places autocomplete search with API-based station search that shows nearest stations based on user's current location.

## Changes Made

### 1. New Widget Created
**File:** `/lib/widgets/station_search_widget.dart`

**Features:**
- Uses station API data instead of Google Places API
- Calculates distance from user's current location to all stations
- Sorts stations by nearest distance
- **Shows top 10 nearest stations ONLY when user taps/clicks the search bar**
- Filters stations by search query (name, address, city, code)
- Displays station information:
  - Station name
  - Full address with city
  - Distance from current location (in km)
  - Available slots / Total capacity
  - Color-coded icon (green = available, red = full)

**Components:**
- `StationSearchWidget` - Main search widget
- `PositionedStationSearchWidget` - Positioned wrapper for map overlay
- `_StationWithDistance` - Helper class to store station with calculated distance

### 2. Home Page Updates
**File:** `/lib/presentation/home/home_page.dart`

**Changes:**
- ✅ Removed Google Places API imports (`dart:convert`, `http`, `google_maps_flutter`, `google_api.dart`)
- ✅ Replaced `search_widget.dart` import with `station_search_widget.dart`
- ✅ Added `_availableStations` state variable to store loaded stations
- ✅ Updated BlocListener to populate `_availableStations` when stations are loaded
- ✅ Replaced `_onPlaceSelected()` with `_onStationSelected()` method
- ✅ Updated search widget in fullscreen map to use `PositionedStationSearchWidget`
- ✅ Updated search widget in normal map view to use `PositionedStationSearchWidget`
- ✅ Increased `perPage` to 100 in `LoadStations()` to fetch more stations for better search results

**New Method - `_onStationSelected(Station station)`:**
```dart
void _onStationSelected(Station station) {
  // Set the station position as destination
  _navigationController.setDestination(station.position);
  
  // Convert to DestinationStation for the bottom sheet
  final destinationStation = _realStationService.convertToDestinationStation(
    station,
    _navigationController.currentPosition,
  );
  
  // Show bottom sheet with station details
  StationBottomSheet.show(
    context,
    station: destinationStation,
    currentPosition: _navigationController.currentPosition,
    onSeeRoutes: () {
      Navigator.pop(context);
      _navigationController.startNavigation();
    },
    onBook: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ScanScreen(station: station)),
      );
    },
  );
}
```

## API Integration

**Endpoint Used:** `https://onecharge.io/api/stations`

**Response Structure:**
```json
{
  "success": true,
  "message": "Stations retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": "...",
        "name": "Station Name",
        "address": "Full Address",
        "city": "City",
        "latitude": "25.xxx",
        "longitude": "55.xxx",
        "available_slots": 10,
        "capacity": 20,
        ...
      }
    ]
  }
}
```

**Search Algorithm:**
1. Fetch all stations from API (up to 100 stations) - **NO suggestions displayed on load**
2. **When user taps/clicks the search bar:**
   - Calculate distance from user's current location to each station using Haversine formula
   - Filter stations by search query (if provided)
   - Sort stations by distance (nearest first)
   - Show top 10 nearest results in dropdown suggestions
3. **When user types in search:**
   - Filter stations by query (name, address, city, code)
   - Re-sort by distance
   - Update suggestions
4. **When user selects a station:**
   - Set as navigation destination
   - Show station details in bottom sheet
   - Display route on map
   - Hide suggestions
5. **When user clicks clear button:**
   - Clear search text
   - Hide suggestions

## User Experience Improvements

### Before:
- Generic Google Places search (any location)
- No distance information
- No station-specific details in search
- Manual navigation to find nearest station

### After:
- Station-specific search only
- **Nearest stations appear only when user taps the search bar**
- Distance displayed for each result
- Available slots shown in search
- Automatically sorted by nearest location
- Color-coded availability indicators
- One-tap selection with instant route display
- Clean UI - no clutter until user interacts with search

## Testing Checklist

- [ ] Search bar shows NO suggestions on initial page load
- [ ] Nearest stations appear ONLY when user taps/clicks the search bar
- [ ] Top 10 nearest stations are displayed sorted by distance
- [ ] Search filters stations by name, address, city, or code when typing
- [ ] Stations remain sorted by distance during search
- [ ] Distance is calculated and displayed correctly in km
- [ ] Selecting a station sets it as destination and hides suggestions
- [ ] Station bottom sheet appears with correct details
- [ ] Route is displayed on map after selection
- [ ] Works in both normal and fullscreen map views
- [ ] Handles empty search results gracefully
- [ ] Clear button removes search text and hides all suggestions
- [ ] Suggestions hide after station selection

## No Breaking Changes

✅ All existing functionality preserved:
- Map display and navigation
- Station markers on map
- Bottom sheet functionality
- Booking/scanning flow
- Navigation controls
- Full-screen map mode

Only the search suggestion mechanism was changed from Google Places to Station API.


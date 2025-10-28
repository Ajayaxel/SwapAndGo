# Waze Routing Troubleshooting Guide

## Issue: "No routes found between start and end" / "Failed to handle route information"

This error occurs when Waze cannot calculate a route between the current location and the destination. Here's how to fix it:

## ✅ **Solutions Implemented**

### 1. **Multiple URL Format Support**
The improved Waze service now tries multiple URL formats:
- `waze://?ll=lat,lng&navigate=yes` (standard coordinates)
- `waze://?q=lat,lng&navigate=yes` (alternative format)
- `waze://?ll=lat,lng&q=station_name&navigate=yes` (with location name)
- `waze://?ll=start_lat,start_lng&ll2=dest_lat,dest_lng&navigate=yes` (with both start and end)

### 2. **Current Location Integration**
- Now passes current location to Waze for better route calculation
- Uses both start and destination coordinates when available
- Falls back to destination-only if current location unavailable

### 3. **Enhanced Error Handling**
- Multiple fallback attempts with different URL formats
- Web version fallback if app fails
- Search-based fallback as final option
- Detailed logging for debugging

### 4. **Coordinate Precision**
- Uses 6 decimal places for better accuracy
- Properly formats coordinates for Waze compatibility

## 🔧 **How It Works Now**

### Step 1: Try App with Multiple Formats
```dart
// Format 1: Standard coordinates
'waze://?ll=37.7749,-122.4194&navigate=yes'

// Format 2: Alternative format
'waze://?q=37.7749,-122.4194&navigate=yes'

// Format 3: With location name
'waze://?ll=37.7749,-122.4194&q=Station%20Name&navigate=yes'

// Format 4: With both start and end
'waze://?ll=37.7749,-122.4194&ll2=37.7849,-122.4094&navigate=yes'
```

### Step 2: Try Web Version
If app fails, tries web versions with same formats.

### Step 3: Search Fallback
If coordinates fail, tries search-based approach:
```dart
'https://waze.com/ul?q=Station%20Name&navigate=yes'
```

## 🧪 **Testing Steps**

### Test 1: With Waze Installed
1. Tap "Directions" on any station
2. Select "Waze"
3. Should open Waze with route

### Test 2: Without Waze
1. Uninstall Waze app
2. Tap "Directions" → "Waze"
3. Should open Waze web version

### Test 3: Debug Mode
Check console for detailed logs:
```
Waze opened successfully with URL: waze://?ll=37.7749,-122.4194&navigate=yes
```

## 🐛 **Common Issues & Solutions**

### Issue: "No routes found"
**Causes:**
- Invalid coordinates
- Waze can't calculate route between points
- Network connectivity issues

**Solutions:**
- ✅ Multiple URL formats (implemented)
- ✅ Search-based fallback (implemented)
- ✅ Web version fallback (implemented)

### Issue: "Failed to handle route information"
**Causes:**
- Waze app not properly installed
- URL scheme not registered
- Permission issues

**Solutions:**
- ✅ Check Waze installation
- ✅ Verify URL schemes in Info.plist
- ✅ Try web version fallback

### Issue: Coordinates not working
**Causes:**
- Wrong coordinate format
- Invalid precision
- Missing current location

**Solutions:**
- ✅ 6 decimal places precision
- ✅ Multiple coordinate formats
- ✅ Current location integration

## 📱 **Platform-Specific Notes**

### iOS
- ✅ URL schemes properly configured
- ✅ LSApplicationQueriesSchemes added
- ✅ Multiple fallback options

### Android
- ✅ Queries for Waze app added
- ✅ Web fallback working
- ✅ Search fallback working

## 🔍 **Debug Information**

Enable debug logging to see what's happening:

```dart
// Check console for these messages:
"Waze opened successfully with URL: [url]"
"Waze app launch failed for URL [url]: [error]"
"Waze web opened successfully with URL: [url]"
"Waze search fallback opened successfully"
```

## 📋 **Verification Checklist**

- [ ] Waze app installed and working
- [ ] Current location permission granted
- [ ] Network connectivity available
- [ ] URL schemes properly configured
- [ ] Multiple fallback options working
- [ ] Debug logging enabled

## 🚀 **Expected Behavior**

### Success Case:
1. User taps "Directions" → "Waze"
2. Waze opens with route to station
3. Route is calculated and displayed

### Fallback Case:
1. User taps "Directions" → "Waze"
2. Waze app fails to open
3. Web version opens with route
4. Route is calculated and displayed

### Search Fallback:
1. User taps "Directions" → "Waze"
2. Coordinate-based URLs fail
3. Search-based URL opens
4. User can search for station manually

## 📞 **If Still Having Issues**

1. **Check Waze App:**
   - Ensure Waze is properly installed
   - Test Waze manually with coordinates
   - Check Waze app permissions

2. **Check Coordinates:**
   - Verify station coordinates are valid
   - Check current location accuracy
   - Test with known good coordinates

3. **Check Network:**
   - Ensure internet connectivity
   - Check if Waze servers are accessible
   - Try different network (WiFi vs Mobile)

4. **Check Logs:**
   - Enable debug logging
   - Check console for error messages
   - Verify which URL format works

The improved implementation should resolve the "No routes found" error by providing multiple fallback options and better coordinate handling.

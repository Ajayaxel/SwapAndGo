# URL Launcher Troubleshooting Guide

## Error: PlatformException(channel-error, Unable to establish connection on channel: "dev.flutter.pigeon.url_launcher_ios.UrlLauncherApi.canLaunchUrl")

This error occurs when the `url_launcher` plugin cannot establish a connection to the native iOS code. Here's how to fix it:

## ✅ **Solution Applied**

### 1. **iOS Info.plist Configuration**
Added the required URL schemes to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>waze</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>waze</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleURLName</key>
        <string>maps</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>maps</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleURLName</key>
        <string>comgooglemaps</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>comgooglemaps</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>waze</string>
    <string>maps</string>
    <string>comgooglemaps</string>
    <string>http</string>
    <string>https</string>
</array>
```

### 2. **Improved Error Handling**
Enhanced both `WazeService` and `AppleMapsService` with:
- Multiple fallback attempts
- Better error logging
- Graceful degradation

### 3. **Build Cleanup**
Performed `flutter clean` and `flutter pub get` to ensure proper plugin registration.

## 🔧 **Additional Steps to Try**

### If the error persists:

1. **Clean and Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

2. **Check iOS Deployment Target:**
   Ensure your `ios/Podfile` has:
   ```ruby
   platform :ios, '11.0'
   ```

3. **Verify URL Launcher Version:**
   Check `pubspec.yaml` for:
   ```yaml
   url_launcher: ^6.2.2
   ```

4. **iOS Simulator vs Device:**
   - Test on a physical device if using simulator
   - Some URL schemes work differently on simulator

5. **Check App Installation:**
   - Ensure Waze app is installed for testing
   - Test with Apple Maps (always available on iOS)

## 🧪 **Testing Steps**

1. **Test Waze Integration:**
   - Install Waze app on device
   - Tap "Directions" → "Waze"
   - Should open Waze with navigation

2. **Test Apple Maps Integration:**
   - Tap "Directions" → "Apple Maps"
   - Should open Apple Maps with navigation

3. **Test Fallback:**
   - Uninstall Waze app
   - Tap "Directions" → "Waze"
   - Should open Waze web version

## 📱 **Platform-Specific Notes**

### iOS
- ✅ Apple Maps app integration
- ✅ Waze app integration (if installed)
- ✅ Web fallback for both

### Android
- ✅ Waze app integration (if installed)
- ✅ Apple Maps web version
- ✅ Google Maps integration (if configured)

## 🐛 **Common Issues & Solutions**

### Issue: "No app found to handle this URL"
**Solution:** The app is not installed. The service will automatically fallback to web version.

### Issue: "Permission denied"
**Solution:** Check that the URL schemes are properly declared in Info.plist.

### Issue: "Channel error" (your specific error)
**Solution:** Clean build and ensure proper plugin registration as done above.

## 📋 **Verification Checklist**

- [ ] Info.plist contains required URL schemes
- [ ] LSApplicationQueriesSchemes includes all needed schemes
- [ ] Flutter clean and rebuild completed
- [ ] Pod install completed (iOS)
- [ ] App tested on physical device
- [ ] Error handling improved in services
- [ ] Fallback mechanisms working

## 🔍 **Debug Information**

To get more detailed error information, check the console output. The improved services now provide detailed logging for each step:

```
Waze app check failed: [error details]
Waze web launch failed: [error details]
Waze search fallback failed: [error details]
```

This will help identify exactly where the process is failing.

## 📞 **If Still Having Issues**

1. Check Flutter and Xcode versions compatibility
2. Verify iOS deployment target matches requirements
3. Test with a minimal URL launcher example
4. Check iOS device logs for more detailed error information

The changes made should resolve the channel error and provide robust fallback mechanisms for all map navigation options.

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class WazeService {
  /// Opens Waze app with navigation to the specified destination
  static Future<void> openInWaze(LatLng destination, String destinationName) async {
    try {
      // Format coordinates with proper precision
      final lat = destination.latitude.toStringAsFixed(6);
      final lng = destination.longitude.toStringAsFixed(6);
      
      // Try multiple Waze URL formats
      final List<String> wazeUrls = [
        // Format 1: Standard coordinates
        'waze://?ll=$lat,$lng&navigate=yes',
        // Format 2: Alternative coordinate format
        'waze://?q=$lat,$lng&navigate=yes',
        // Format 3: With location name
        'waze://?ll=$lat,$lng&q=${Uri.encodeComponent(destinationName)}&navigate=yes',
      ];
      
      // Try each Waze URL format
      for (String wazeUrl in wazeUrls) {
        try {
          if (await canLaunchUrl(Uri.parse(wazeUrl))) {
            await launchUrl(Uri.parse(wazeUrl));
            debugPrint('Waze opened successfully with URL: $wazeUrl');
            return;
          }
        } catch (e) {
          debugPrint('Waze app launch failed for URL $wazeUrl: $e');
        }
      }
      
      // If Waze app is not installed, try web versions with better URL formats
      final List<String> webUrls = [
        // Format 1: Direct coordinates with navigation
        'https://waze.com/ul?ll=$lat,$lng&navigate=yes',
        // Format 2: Coordinates as query
        'https://waze.com/ul?q=$lat,$lng&navigate=yes',
        // Format 3: Station name with navigation
        'https://waze.com/ul?q=${Uri.encodeComponent(destinationName)}&navigate=yes',
        // Format 4: Direct coordinates without navigate (sometimes works better)
        'https://waze.com/ul?ll=$lat,$lng',
        // Format 5: Station name without navigate
        'https://waze.com/ul?q=${Uri.encodeComponent(destinationName)}',
        // Format 6: Alternative parameter names
        'https://waze.com/ul?daddr=$lat,$lng',
        // Format 7: Address format
        'https://waze.com/ul?address=${Uri.encodeComponent(destinationName)}',
      ];
      
      for (String webUrl in webUrls) {
        try {
          if (await canLaunchUrl(Uri.parse(webUrl))) {
            await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
            debugPrint('Waze web opened successfully with URL: $webUrl');
            return;
          }
        } catch (e) {
          debugPrint('Waze web launch failed for URL $webUrl: $e');
        }
      }
      
      // Final fallback - try with just the search query
      final searchUrl = 'https://waze.com/ul?q=${Uri.encodeComponent(destinationName)}';
      try {
        if (await canLaunchUrl(Uri.parse(searchUrl))) {
          await launchUrl(Uri.parse(searchUrl), mode: LaunchMode.externalApplication);
          debugPrint('Waze search fallback opened successfully');
          return;
        }
      } catch (e) {
        debugPrint('Waze search fallback failed: $e');
      }
      
      // If all attempts fail, show error message
      debugPrint('Could not open Waze. Please install Waze app or check your internet connection.');
      
    } catch (e) {
      debugPrint('Error opening Waze: $e');
    }
  }

  /// Checks if Waze app is installed on the device
  static Future<bool> isWazeInstalled() async {
    try {
      final wazeUrl = 'waze://';
      return await canLaunchUrl(Uri.parse(wazeUrl));
    } catch (e) {
      debugPrint('Error checking Waze installation: $e');
      return false;
    }
  }

  /// Opens Waze with search query instead of coordinates
  static Future<void> openInWazeWithSearch(String searchQuery) async {
    try {
      // Waze search URL format: waze://?q=search_query&navigate=yes
      final encodedQuery = Uri.encodeComponent(searchQuery);
      final wazeUrl = 'waze://?q=$encodedQuery&navigate=yes';
      
      if (await canLaunchUrl(Uri.parse(wazeUrl))) {
        await launchUrl(Uri.parse(wazeUrl));
        return;
      }
      
      // Fallback to web version
      final webUrl = 'https://waze.com/ul?q=$encodedQuery&navigate=yes';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
        return;
      }
      
      debugPrint('Could not open Waze with search query.');
      
    } catch (e) {
      debugPrint('Error opening Waze with search: $e');
    }
  }

  /// Opens Waze with both current location and destination for better routing
  static Future<void> openInWazeWithRoute(LatLng? currentLocation, LatLng destination, String destinationName) async {
    try {
      // Format coordinates with proper precision
      final destLat = destination.latitude.toStringAsFixed(6);
      final destLng = destination.longitude.toStringAsFixed(6);
      
      // Try Waze app first, but with immediate fallback to web
      bool appSuccess = await _tryWazeApp(destLat, destLng, destinationName, currentLocation);
      
      if (!appSuccess) {
        // If app failed, immediately try web version
        debugPrint('Waze app failed, trying web version...');
        await _openWazeWebVersion(destLat, destLng, destinationName);
      }
      
    } catch (e) {
      debugPrint('Error opening Waze with route: $e');
      // Final fallback
      await openInWazeWithSearch(destinationName);
    }
  }

  /// Try to open Waze app with multiple URL formats
  static Future<bool> _tryWazeApp(String destLat, String destLng, String destinationName, LatLng? currentLocation) async {
    try {
      // Try different URL formats based on whether we have current location
      List<String> wazeUrls = [];
      
      if (currentLocation != null) {
        final currLat = currentLocation.latitude.toStringAsFixed(6);
        final currLng = currentLocation.longitude.toStringAsFixed(6);
        
        // Include both start and end points for better routing
        wazeUrls = [
          'waze://?ll=$destLat,$destLng&navigate=yes',
          'waze://?q=$destLat,$destLng&navigate=yes',
          'waze://?ll=$destLat,$destLng&q=${Uri.encodeComponent(destinationName)}&navigate=yes',
          // Try with both start and end coordinates
          'waze://?ll=$currLat,$currLng&ll2=$destLat,$destLng&navigate=yes',
        ];
      } else {
        // Fallback to destination only
        wazeUrls = [
          'waze://?ll=$destLat,$destLng&navigate=yes',
          'waze://?q=$destLat,$destLng&navigate=yes',
          'waze://?ll=$destLat,$destLng&q=${Uri.encodeComponent(destinationName)}&navigate=yes',
        ];
      }
      
      // Try each Waze URL format with timeout
      for (String wazeUrl in wazeUrls) {
        try {
          if (await canLaunchUrl(Uri.parse(wazeUrl))) {
            // Try to launch with a timeout
            await launchUrl(Uri.parse(wazeUrl)).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                throw Exception('Launch timeout');
              },
            );
            debugPrint('Waze opened successfully with route URL: $wazeUrl');
            return true;
          }
        } catch (e) {
          debugPrint('Waze route launch failed for URL $wazeUrl: $e');
          // Continue to next URL format
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error trying Waze app: $e');
      return false;
    }
  }


  /// Open Waze web version with multiple fallback options
  static Future<void> _openWazeWebVersion(String lat, String lng, String destinationName) async {
    // Try different web URL formats that work better with Waze web
    final List<String> webUrls = [
      // Format 1: Direct coordinates with navigation
      'https://waze.com/ul?ll=$lat,$lng&navigate=yes',
      // Format 2: Coordinates as query
      'https://waze.com/ul?q=$lat,$lng&navigate=yes',
      // Format 3: Station name with navigation
      'https://waze.com/ul?q=${Uri.encodeComponent(destinationName)}&navigate=yes',
      // Format 4: Direct coordinates without navigate (sometimes works better)
      'https://waze.com/ul?ll=$lat,$lng',
      // Format 5: Station name without navigate
      'https://waze.com/ul?q=${Uri.encodeComponent(destinationName)}',
      // Format 6: Alternative Waze web format
      'https://waze.com/ul?q=$lat,$lng',
      // Format 7: Try with different parameter names
      'https://waze.com/ul?daddr=$lat,$lng',
      // Format 8: Try with address format
      'https://waze.com/ul?address=${Uri.encodeComponent(destinationName)}',
      // Format 9: Try Google Maps style URL (sometimes works better)
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      // Format 10: Try with different Waze web domain
      'https://waze.com/ul?q=${Uri.encodeComponent(destinationName)}&ll=$lat,$lng',
    ];
    
    for (String webUrl in webUrls) {
      try {
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
          debugPrint('Waze web opened successfully with URL: $webUrl');
          return;
        }
      } catch (e) {
        debugPrint('Waze web launch failed for URL $webUrl: $e');
      }
    }
    
    // If all web attempts fail, try the search fallback
    debugPrint('All Waze web attempts failed, trying search fallback...');
    await openInWazeWithSearch(destinationName);
  }
}

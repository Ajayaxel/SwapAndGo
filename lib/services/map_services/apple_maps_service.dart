import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class AppleMapsService {
  /// Opens Apple Maps app with navigation to the specified destination
  static Future<void> openInAppleMaps(LatLng destination, String destinationName) async {
    try {
      String url;
      
      if (Platform.isIOS) {
        // iOS Apple Maps URL format: maps://?daddr=latitude,longitude
        url = 'maps://?daddr=${destination.latitude},${destination.longitude}';
      } else {
        // Android - open in browser with Apple Maps web version
        url = 'https://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}';
      }
      
      // Try to launch the primary URL
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint('Apple Maps primary launch failed: $e');
      }
      
      // Fallback to web version for all platforms
      final webUrl = 'https://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}';
      try {
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint('Apple Maps web launch failed: $e');
      }
      
      // Final fallback - try with search query
      final searchUrl = 'https://maps.apple.com/?q=${Uri.encodeComponent(destinationName)}';
      try {
        if (await canLaunchUrl(Uri.parse(searchUrl))) {
          await launchUrl(Uri.parse(searchUrl), mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        debugPrint('Apple Maps search fallback failed: $e');
      }
      
      debugPrint('Could not open Apple Maps. Please check your internet connection.');
      
    } catch (e) {
      debugPrint('Error opening Apple Maps: $e');
    }
  }

  /// Opens Apple Maps with search query instead of coordinates
  static Future<void> openInAppleMapsWithSearch(String searchQuery) async {
    try {
      String url;
      final encodedQuery = Uri.encodeComponent(searchQuery);
      
      if (Platform.isIOS) {
        // iOS Apple Maps search URL format: maps://?q=search_query
        url = 'maps://?q=$encodedQuery';
      } else {
        // Android - open in browser
        url = 'https://maps.apple.com/?q=$encodedQuery';
      }
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return;
      }
      
      // Fallback to web version
      final webUrl = 'https://maps.apple.com/?q=$encodedQuery';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
        return;
      }
      
      debugPrint('Could not open Apple Maps with search query.');
      
    } catch (e) {
      debugPrint('Error opening Apple Maps with search: $e');
    }
  }

  /// Checks if Apple Maps app is available (iOS only)
  static Future<bool> isAppleMapsAvailable() async {
    if (!Platform.isIOS) return false;
    
    try {
      final mapsUrl = 'maps://';
      return await canLaunchUrl(Uri.parse(mapsUrl));
    } catch (e) {
      debugPrint('Error checking Apple Maps availability: $e');
      return false;
    }
  }
}

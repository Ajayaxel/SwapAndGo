import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../services/map_services/waze_service.dart';
import '../../services/map_services/apple_maps_service.dart';

class MapChoiceModal extends StatelessWidget {
  final LatLng destination;
  final String destinationName;
  final VoidCallback onCurrentMapSelected;
  final LatLng? currentLocation;

  const MapChoiceModal({
    super.key,
    required this.destination,
    required this.destinationName,
    required this.onCurrentMapSelected,
    this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.5, // Maximum 50% of screen height
        minHeight: 280, // Minimum height to ensure content fits
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use minimum space needed
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Text(
                  'Choose Navigation App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Navigate to $destinationName',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Map options - using Flexible to prevent overflow
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16 + safeAreaBottom, // Add safe area bottom padding
              ),
              child: Column(
                children: [
                  // Current Map (Google Maps in app)
                  _buildMapOption(
                    context: context,
                    icon: Icons.map,
                    title: 'Current Map',
                    subtitle: 'Navigate using in-app map',
                    color: const Color(0xFF4285F4),
                    onTap: () {
                      Navigator.pop(context);
                      onCurrentMapSelected();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Apple Maps - Only show on iOS
                  if (Platform.isIOS) ...[
                    _buildMapOption(
                      context: context,
                      icon: Icons.apple,
                      title: 'Apple Maps',
                      subtitle: 'Open in Apple Maps app',
                      color: const Color(0xFF007AFF),
                      onTap: () {
                        Navigator.pop(context);
                        AppleMapsService.openInAppleMaps(destination, destinationName);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Google Maps - Only show on Android
                  if (Platform.isAndroid) ...[
                    _buildMapOption(
                      context: context,
                      icon: Icons.map_outlined,
                      title: 'Google Maps',
                      subtitle: 'Open in Google Maps app',
                      color: const Color(0xFF4285F4),
                      onTap: () {
                        Navigator.pop(context);
                        MapChoiceModal._openInGoogleMaps(destination, destinationName);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Waze
                  _buildMapOption(
                    context: context,
                    icon: Icons.navigation,
                    title: 'Waze',
                    subtitle: 'Open in Waze app',
                    color: const Color(0xFF33CCFF),
                    onTap: () {
                      Navigator.pop(context);
                      // Use the improved Waze service with current location for better routing
                      WazeService.openInWazeWithRoute(currentLocation, destination, destinationName);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens Google Maps app with navigation to the specified destination
  static Future<void> _openInGoogleMaps(LatLng destination, String destinationName) async {
    try {
      final lat = destination.latitude.toStringAsFixed(6);
      final lng = destination.longitude.toStringAsFixed(6);
      
      // Try Google Maps app first
      final googleMapsUrl = 'google.navigation:q=$lat,$lng';
      
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
        return;
      }
      
      // Fallback to web version
      final webUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
      
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
        return;
      }
      
      // Final fallback with search
      final searchUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destinationName)}';
      
      if (await canLaunchUrl(Uri.parse(searchUrl))) {
        await launchUrl(Uri.parse(searchUrl), mode: LaunchMode.externalApplication);
        return;
      }
      
      debugPrint('Could not open Google Maps');
      
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
    }
  }
}

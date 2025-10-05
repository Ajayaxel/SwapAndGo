import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/navigation_models.dart';
import '../services/map_service.dart';

class StationBottomSheet extends StatelessWidget {
  final DestinationStation station;
  final VoidCallback onSeeRoutes;
  final VoidCallback onBook;
  final LatLng? currentPosition;

  const StationBottomSheet({
    super.key,
    required this.station,
    required this.onSeeRoutes,
    required this.onBook,
    this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    final mapService = MapService();
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Station icon
          Image.asset(
            "asset/home/bookicon.png",
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 20),

          // Station info
          Text(
            station.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${station.type} • ${station.availableSlots} slots available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          if (currentPosition != null)
            Text(
              '${mapService.calculateDistance(
                currentPosition!.latitude,
                currentPosition!.longitude,
                station.position.latitude,
                station.position.longitude,
              ).toStringAsFixed(1)} km away',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSeeRoutes,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'See Routes',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0A2342),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Swap now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Show station bottom sheet
  static void show(
    BuildContext context, {
    required DestinationStation station,
    required VoidCallback onSeeRoutes,
    required VoidCallback onBook,
    LatLng? currentPosition,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StationBottomSheet(
        station: station,
        onSeeRoutes: onSeeRoutes,
        onBook: onBook,
        currentPosition: currentPosition,
      ),
    );
  }
}

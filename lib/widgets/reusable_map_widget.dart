import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/navigation_models.dart';
import '../services/map_service.dart';

class ReusableMapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  final bool compassEnabled;
  final double zoom;
  final double? tilt;
  final double? bearing;
  final LatLngBounds? bounds;
  final Function(GoogleMapController)? onMapCreated;
  final VoidCallback? onMapTap;

  const ReusableMapWidget({
    super.key,
    this.initialPosition,
    this.markers = const {},
    this.polylines = const {},
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.zoomControlsEnabled = true,
    this.mapToolbarEnabled = true,
    this.compassEnabled = true,
    this.zoom = 14.0,
    this.tilt,
    this.bearing,
    this.bounds,
    this.onMapCreated,
    this.onMapTap,
  });

  @override
  State<ReusableMapWidget> createState() => _ReusableMapWidgetState();
}

class _ReusableMapWidgetState extends State<ReusableMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLngBounds? _lastBounds;

  @override
  void didUpdateWidget(ReusableMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update camera bounds if bounds have changed
    if (widget.bounds != null && widget.bounds != _lastBounds) {
      _lastBounds = widget.bounds;
      _updateCameraBounds();
    }
  }

  Future<void> _updateCameraBounds() async {
    if (widget.bounds == null) return;
    
    try {
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(widget.bounds!, 100.0),
      );
    } catch (e) {
      debugPrint('Error updating camera bounds: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition!,
        zoom: widget.zoom,
        tilt: widget.tilt ?? 0,
        bearing: widget.bearing ?? 0,
      ),
      markers: widget.markers,
      polylines: widget.polylines,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      compassEnabled: widget.compassEnabled,
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
        widget.onMapCreated?.call(controller);
      },
      onTap: (_) => widget.onMapTap?.call(),
    );
  }

  /// Get the map controller
  Future<GoogleMapController> get controller => _controller.future;

  /// Animate camera to position
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    final controller = await _controller.future;
    controller.animateCamera(cameraUpdate);
  }

  /// Move camera to position
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    final controller = await _controller.future;
    controller.moveCamera(cameraUpdate);
  }
}

/// Navigation map widget for turn-by-turn navigation
class NavigationMapWidget extends StatelessWidget {
  final LatLng currentPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final NavStep? currentStep;
  final double? distanceKm;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback onExitNavigation;
  final Function(GoogleMapController)? onMapCreated;

  const NavigationMapWidget({
    super.key,
    required this.currentPosition,
    required this.markers,
    required this.polylines,
    this.currentStep,
    this.distanceKm,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onExitNavigation,
    this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    final mapService = MapService();

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          ReusableMapWidget(
            initialPosition: currentPosition,
            markers: markers,
            polylines: polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            zoom: 18.5,
            tilt: 65,
            onMapCreated: onMapCreated,
          ),

          // Top navigation instruction card
          if (currentStep != null)
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: _buildNavigationCard(mapService),
            ),

          // Exit navigation button
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onExitNavigation,
                icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),

          // Bottom speed and ETA card
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildBottomInfoCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(MapService mapService) {
    final distanceToNextTurn = currentStep != null
        ? mapService.calculateDistance(
            currentPosition.latitude,
            currentPosition.longitude,
            currentStep!.end.latitude,
            currentStep!.end.longitude,
          ) * 1000 // Convert to meters
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  mapService.getManeuverIcon(currentStep?.maneuver),
                  size: 32,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distanceToNextTurn < 1000
                          ? '${distanceToNextTurn.toStringAsFixed(0)} m'
                          : '${(distanceToNextTurn / 1000).toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStep?.instruction ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${distanceKm?.toStringAsFixed(1) ?? '0'} km remaining',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                'Step ${currentStepIndex + 1} of $totalSteps',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.access_time, color: Colors.purple),
              const SizedBox(height: 4),
              Text(
                '${(distanceKm ?? 0 * 2).toStringAsFixed(0)} min',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'ETA',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          Column(
            children: [
              const Icon(Icons.speed, color: Colors.purple),
              const SizedBox(height: 4),
              const Text(
                '45',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'km/h',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          Column(
            children: [
              const Icon(Icons.route, color: Colors.purple),
              const SizedBox(height: 4),
              Text(
                '${distanceKm?.toStringAsFixed(1) ?? '0'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'km left',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

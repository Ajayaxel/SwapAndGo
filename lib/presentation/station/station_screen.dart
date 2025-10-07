import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swap_app/bloc/station/station_bloc.dart';
import 'package:swap_app/bloc/station/station_event.dart';
import 'package:swap_app/bloc/station/station_state.dart';
import 'package:swap_app/presentation/station/scan_screen.dart';
import 'package:swap_app/repo/station_repository.dart';
import '../../controllers/navigation_controller.dart';
import '../../widgets/reusable_map_widget.dart';
import '../../services/real_station_service.dart';
import '../../model/station_model.dart';

final GlobalKey<StationScreenState> stationScreenKey =
    GlobalKey<StationScreenState>();

class StationScreen extends StatefulWidget {
  const StationScreen({super.key});

  @override
  State<StationScreen> createState() => StationScreenState();
}

class StationScreenState extends State<StationScreen> {
  late NavigationController _navigationController;
  final RealStationService _realStationService = RealStationService();
  bool _isFullscreenNavigation = false;

  @override
  void initState() {
    super.initState();
    _navigationController = NavigationController();
    _initializeMap();
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _navigationController.initialize();
    // Stations will be loaded when the bloc loads them
  }

  /// near by station tap on google map function
  void _onMapStationTap(Station station) {
    // Show station modal when tapped
        showStationModal(context, station);
    
  }

  void _updateMapMarkers(List<Station> stations) {
    final stationMarkers = _realStationService.createStationMarkers(
      stations,
      _onMapStationTap,
    );

    _navigationController.addStationMarkers(stationMarkers);

    // Update map bounds to show all stations
    if (stations.isNotEmpty) {
      _updateMapBounds(stations);
    }
  }

  void _updateMapBounds(List<Station> stations) {
    if (stations.isEmpty) return;

    double minLat = stations.first.position.latitude;
    double maxLat = stations.first.position.latitude;
    double minLng = stations.first.position.longitude;
    double maxLng = stations.first.position.longitude;

    for (final station in stations) {
      minLat = minLat < station.position.latitude
          ? minLat
          : station.position.latitude;
      maxLat = maxLat > station.position.latitude
          ? maxLat
          : station.position.latitude;
      minLng = minLng < station.position.longitude
          ? minLng
          : station.position.longitude;
      maxLng = maxLng > station.position.longitude
          ? maxLng
          : station.position.longitude;
    }

    // Add padding to bounds
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    _navigationController.updateMapBounds(bounds);
  }

  // Helper method to set station as destination for navigation
  void _setStationAsDestination(Station station) {
    _navigationController.setDestination(station.position);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _navigationController,
      builder: (context, child) {
        // Show full-screen navigation if active
        if (_isFullscreenNavigation && _navigationController.isNavigationMode) {
          return _buildFullscreenNavigation();
        }

        // Show normal station screen with map
        return _buildStationScreen();
      },
    );
  }

  Widget _buildFullscreenNavigation() {
    return NavigationMapWidget(
      currentPosition: _navigationController.currentPosition!,
      markers: _navigationController.markers,
      polylines: _navigationController.polylines,
      currentStep: _navigationController.currentStep,
      distanceKm: _navigationController.currentRoute?.distanceKm,
      currentStepIndex: _navigationController.currentStepIndex,
      totalSteps: _navigationController.currentRoute?.navSteps.length ?? 0,
      onExitNavigation: () {
        setState(() {
          _isFullscreenNavigation = false;
        });
        _navigationController.stopNavigation();
      },
    );
  }

  Widget _buildStationScreen() {
    return BlocProvider(
      create: (_) => StationBloc(StationRepository())..add(LoadStations()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background Google Map
            Positioned.fill(
              child: ReusableMapWidget(
                initialPosition: _navigationController.currentPosition,
                markers: _navigationController.markers,
                polylines: _navigationController.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                zoom: 12.0,
              ),
            ),

            // Top Gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              top: 40,
              left: 16,
              child: BlocBuilder<StationBloc, StationState>(
                builder: (context, state) {
                  int stationCount = 0;
                  if (state is StationLoaded) {
                    stationCount = state.stations.length;
                  }
                  return Text(
                    stationCount > 0
                        ? "$stationCount Stations in this area"
                        : "Stations",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                },
              ),
            ),

            // Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                  color: Color(0xffF3F3F3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: BlocConsumer<StationBloc, StationState>(
                  listener: (context, state) {
                    if (state is StationLoaded &&
                        state.selectedStation != null) {
                      showStationModal(context, state.selectedStation!);
                    }
                  },
                  builder: (context, state) {
                    if (state is StationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is StationLoaded) {
                      // Update map markers when stations are loaded
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateMapMarkers(state.stations);
                      });

                      return ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.stations.length,
                        itemBuilder: (context, index) {
                          final station = state.stations[index];

                          // Calculate distance from current position
                          double distance = 0.0;
                          String timeText = station.is24x7 ? "24x7" : "Limited";

                          if (_navigationController.currentPosition != null) {
                            distance = _realStationService.calculateDistance(
                              _navigationController.currentPosition!.latitude,
                              _navigationController.currentPosition!.longitude,
                              station.position.latitude,
                              station.position.longitude,
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: GestureDetector(
                              onTap: () {
                                showStationModal(context, station);
                              },
                              child: stationCard(
                                context: context,
                                station: station,
                                distance: distance,
                                time: timeText,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is StationError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // staion details bottom sheet
  void showStationModal(BuildContext context, Station station) {
    // Calculate distance and time
    double distance = 0.0;
    int estimatedMinutes = 0;

    if (_navigationController.currentPosition != null) {
      distance = _realStationService.calculateDistance(
        _navigationController.currentPosition!.latitude,
        _navigationController.currentPosition!.longitude,
        station.position.latitude,
        station.position.longitude,
      );
      // Estimate time based on distance (average speed 30 km/h)
      estimatedMinutes = (distance * 2).round();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            SizedBox(height: 16),
            // Header with close button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Station info
                    Row(
                      children: [
                        const Icon(
                          Icons.battery_charging_full,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            station.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$estimatedMinutes min away',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Address
                    Text(
                      '${station.address}, ${station.city},\n${station.state}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 24),

                    // Station type and available slots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Public Swap Station",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0A2342),
                          ),
                        ),
                        Text(
                          "Available Slots: ${station.availableSlots}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xffA5CE39),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // Set destination and show full-screen navigation
                              _setStationAsDestination(station);
                              setState(() {
                                _isFullscreenNavigation = true;
                              });
                              _navigationController.startNavigation();
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.directions, size: 16),
                                const SizedBox(width: 8),
                                const Text('Directions'),
                              ],
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () => _callCustomerCare(station.contactNumber),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, size: 16),
                                const SizedBox(width: 8),
                                const Text('Customer Care'),
                              ],
                            ),
                          ),
                        ),

                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[100],
                          child: const Icon(Icons.share, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// details
                    Text(
                      "Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0A2342),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "chargeing capacity",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${station.capacity} kWh",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),
                    const Divider(color: Color(0xffE6EAED), thickness: 2),
                    // working hours
                    Text(
                      "Working Hours",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff0A2342)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${station.operatingHours?.toString()}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget stationCard({
    required BuildContext context,
    required Station station,
    required double distance,
    required String time,
  }) {
    // Determine if station is available
    final isAvailable = station.availableSlots > 0;
    final statusColor = isAvailable ? Colors.green : Colors.red;
    final statusText = isAvailable ? 'Available' : 'Occupied';

    // Format distance (convert km to meters if less than 1km)
    final distanceText = distance < 1.0
        ? '${(distance * 1000).toInt()} m'
        : '${distance.toStringAsFixed(1)} km';

    // Format timing
    final timingText = station.is24x7 ? '24x7' : 'Limited Hours';

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with station name and distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.electric_bolt,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          station.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  distanceText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address and time away
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${station.address}, ${station.city}, ${station.state}, ${station.country}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '0 min away', // This could be calculated based on distance
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons row
            // directions and customer care
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Set destination and show full-screen navigation
                      _setStationAsDestination(station);
                      setState(() {
                        _isFullscreenNavigation = true;
                      });
                      _navigationController.startNavigation();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.directions, size: 16),
                        const SizedBox(width: 8),
                        const Text('Directions'),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => _callCustomerCare(station.contactNumber),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 16),
                        const SizedBox(width: 8),
                        const Text('Customer Care'),
                      ],
                    ),
                  ),
                ),

                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[100],
                  child: const Icon(Icons.share, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info boxes row
            Row(
              children: [
                Expanded(
                  child: infoBox(
                    label: 'Timings',
                    value: timingText,
                    valueColor: station.is24x7 ? Colors.green : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: infoBox(
                    label: 'Station',
                    value:
                        '${station.availableSlots}/${station.capacity} available',
                    valueColor: isAvailable ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: infoBox(
                    label: 'Price',
                    value: 'AED 1/min+Tax',
                    valueColor: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scan & Swap button
            SizedBox(
              width: double.infinity,

              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanScreen(station: station),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF0A2342)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                child: const Text(
                  'Scan & Swap',
                  style: TextStyle(
                    color: Color(0xFF0A2342),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoBox({
    required String label,
    required String value,
    Color valueColor = Colors.black87,
  }) {
    return SizedBox(
      width: 118,
      height: 58,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Method to call customer care
  void _callCustomerCare(String contactNumber) {
    // This would typically use url_launcher to make a phone call
    // For now, we'll show a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Customer Care'),
          content: Text('Call $contactNumber'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

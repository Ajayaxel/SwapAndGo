import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/station/station_bloc.dart';
import 'package:swap_app/bloc/station/station_event.dart';
import 'package:swap_app/bloc/station/station_state.dart';
import 'package:swap_app/presentation/station/scan_screen.dart';
import 'package:swap_app/presentation/station/scan_suceess_screen.dart';
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

  void _onMapStationTap(Station station) {
    // Show route to station
    _navigationController.setDestination(station.position);
    
    // Show bottom sheet with real station data
    // showStationModal(context, station);
  }

  void _updateMapMarkers(List<Station> stations) {
    if (_navigationController.currentPosition != null) return;

    final stationMarkers = _realStationService.createStationMarkers(
      stations,
      _onMapStationTap,
    );

    _navigationController.addStationMarkers(stationMarkers);
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
      create: (_) => StationBloc(StationRepository())..add(LoadStations(selectedStation: selectedStation)),
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
                    colors: [Colors.black.withValues(alpha: 0.2), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Title
            const Positioned(
              top: 40,
              left: 16,
              child: Text(
                "Stations",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
                    if (state is StationLoaded && state.selectedStation != null) {
                      showStationModal(context, state.selectedStation!);
                      selectedStation=null;
                     
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
                                // showStationModal(context, station);
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
        height: MediaQuery.of(context).size.height * 0.5,
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

            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Image.asset(
                    "asset/home/smallogo.png",
                    height: 30,
                    width: 75,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.bookmark_border),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
                      '${station.address}, ${station.city}, ${station.state}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 24),

                    // Info boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Timings',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                station.is24x7 ? '24x7' : 'Limited',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Station',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${station.availableSlots}/${station.capacity} available',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                station.type,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Contact info if available
                    if (station.contactNumber.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Contact: ${station.contactNumber}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xffE6EAED), thickness: 2),

                    const Spacer(),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Set destination and show full-screen navigation
                                _setStationAsDestination(station);
                                setState(() {
                                  _isFullscreenNavigation = true;
                                });
                                _navigationController.startNavigation();
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: Color(0xFF0A2342)),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
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
                              onPressed: () {
                                // Navigator.pop(context);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>  ScanScreen(station: station),
                                //   ),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A2342),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.battery_charging_full,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
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
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(time, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${station.address}, ${station.city}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                infoBox(label: 'Timings', value: time),
                infoBox(label: 'Station', value: '${station.availableSlots}/${station.capacity}'),
                infoBox(label: 'Type', value: station.type),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ScanScreen(station: station)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text(
                  'Scan & Swap',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: label == 'Station' ? Colors.green : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

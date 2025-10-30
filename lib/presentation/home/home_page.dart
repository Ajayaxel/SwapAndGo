import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/model/station_model.dart';
import 'package:swap_app/bloc/station/station_bloc.dart';
import 'package:swap_app/bloc/station/station_event.dart';
import 'package:swap_app/bloc/station/station_state.dart';
import 'package:swap_app/presentation/station/scan_screen.dart';
import 'package:swap_app/repo/station_repository.dart';
import '../../bloc/auth_bloc.dart';
import '../../const/go_button.dart';
import '../../controllers/navigation_controller.dart';

import '../../services/real_station_service.dart';
import '../../widgets/reusable_map_widget.dart';
import '../../widgets/station_search_widget.dart';
import '../../widgets/station_bottom_sheet.dart';
import '../map_choice/map_choice_modal.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeContentModularState();
}

class _HomeContentModularState extends State<HomePage> with WidgetsBindingObserver {
  late NavigationController _navigationController;
  final RealStationService _realStationService = RealStationService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isFullscreenMap = false;
  List<Station> _availableStations = [];
  bool _isPermissionDialogShown = false;

  String? _locationName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _navigationController = NavigationController();
    _initializeApp();
    _navigationController.addListener(_fetchLocationNameIfNeeded);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navigationController.removeListener(_fetchLocationNameIfNeeded);
    _navigationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When app comes back to foreground, check permission status
      _checkAndRefreshLocationPermission();
    }
  }

  Future<void> _initializeApp() async {
    await _navigationController.initialize();
    // Stations will be loaded via BlocProvider
    _checkAndRefreshLocationPermission();
  }

  Future<void> _checkAndRefreshLocationPermission() async {
    if (!mounted) return;
    
    // Check comprehensive location permission status
    LocationPermissionStatus status = await _navigationController.checkLocationPermissionStatus();
    
    debugPrint('Current location permission status: $status');
    
    if (status == LocationPermissionStatus.granted) {
      // Reset flag when permission is granted
      _isPermissionDialogShown = false;
      // Refresh location if permission is granted
      await _navigationController.refreshLocation();
    } else if (!_isPermissionDialogShown) {
      // Only show once per session
      _isPermissionDialogShown = true;
      
      // Always request permission to show native dialog
      // This will show the native permission dialog for any denied state
      debugPrint('Requesting location permission...');
      await _navigationController.requestLocationPermission();
    }
  }

  void _onStationTap(Station station) {
    // Show route to station
    _navigationController.setDestination(station.position);
    
    // Convert to DestinationStation for the bottom sheet
    final destinationStation = _realStationService.convertToDestinationStation(
      station,
      _navigationController.currentPosition,
    );
    
    // Show bottom sheet
    StationBottomSheet.show(
      context,
      station: destinationStation,
      currentPosition: _navigationController.currentPosition,
      onSeeRoutes: () {
        Navigator.pop(context);
        _showMapChoiceModal(station);
      },
      onBook: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>  ScanScreen(station: station)),
        );

      },
    );
  }

  // Show map choice modal for directions
  void _showMapChoiceModal(Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapChoiceModal(
        destination: station.position,
        destinationName: station.name,
        currentLocation: _navigationController.currentPosition,
        onCurrentMapSelected: () {
          // Set destination and start navigation
          _navigationController.setDestination(station.position);
          _navigationController.startNavigation();
        },
      ),
    );
  }



  void _updateMapMarkers(List<Station> stations) {
    final stationMarkers = _realStationService.createStationMarkers(
      stations,
      _onStationTap,
    );

    _navigationController.addStationMarkers(stationMarkers);
  }

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
        _showMapChoiceModal(station);
      },
      onBook: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ScanScreen(station: station)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StationBloc(StationRepository())..add(LoadStations(perPage: 100)),
      child: BlocListener<StationBloc, StationState>(
        listener: (context, state) {
          if (state is StationLoaded) {
            setState(() {
              _availableStations = state.stations;
            });
            _updateMapMarkers(state.stations);
          }
        },
        child: ListenableBuilder(
          listenable: _navigationController,
          builder: (context, child) {
            // Show navigation view if in navigation mode
            if (_navigationController.isNavigationMode) {
              return NavigationMapWidget(
                currentPosition: _navigationController.currentPosition!,
                markers: _navigationController.markers,
                polylines: _navigationController.polylines,
                currentStep: _navigationController.currentStep,
                distanceKm: _navigationController.currentRoute?.distanceKm,
                currentStepIndex: _navigationController.currentStepIndex,
                totalSteps: _navigationController.currentRoute?.navSteps.length ?? 0,
                onExitNavigation: () {
                  _navigationController.stopNavigation();
                },
              );
            }

            // Show fullscreen map if enabled
            if (_isFullscreenMap) {
              return _buildFullscreenMap();
            }

            // Show normal home content
            return _buildHomeContent();
          },
        ),
      ),
    );
  }

  Widget _buildFullscreenMap() {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          ReusableMapWidget(
            initialPosition: _navigationController.currentPosition,
            markers: _navigationController.markers,
            polylines: _navigationController.polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoom: 14.0,
          ),

          // Exit fullscreen button
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
                onPressed: () {
                  setState(() {
                    _isFullscreenMap = false;
                  });
                },
                icon: const Icon(
                  Icons.fullscreen_exit,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),

          // Search bar
          PositionedStationSearchWidget(
            top: 50,
            left: 16,
            right: 80, // Leave space for exit button
            hintText: 'Find swap stations',
            onStationSelected: _onStationSelected,
            controller: _searchController,
            stations: _availableStations,
            currentPosition: _navigationController.currentPosition,
          ),

          // Start navigation button (if destination is selected)
          if (_navigationController.destinationPosition != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GoButton(
                onPressed: () {
                  _navigationController.startNavigation();
                },
                text: "START NAVIGATION",
                backgroundColor: Color(0xff0A2342),
                textColor: Colors.white,
                foregroundColor: const Color.fromARGB(255, 97, 81, 81),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section
            _buildGreetingSection(),

            // Distance display
            if (_navigationController.currentRoute != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Distance: ${_navigationController.currentRoute!.distanceKm.toStringAsFixed(2)} km',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // Map + Search section
            _buildMapSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return Text(
                  'Hi ${state.customer.name},',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                );
              } else if (state is AuthLoading) {
                return const Text(
                  'Hi ...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                );
              } else {
                return const Text(
                  'Hi Guest,',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 4),
          const Text('Welcome', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 4),
              Text(
                _navigationController.currentPosition != null
                    ? (_locationName ?? 'Fetching address...')
                    : 'Fetching location...',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Battery status
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Baseline(
          //       baseline: 65,
          //       baselineType: TextBaseline.alphabetic,
          //       child: const Icon(Icons.battery_3_bar, size: 70),
          //     ),
          //     const SizedBox(width: 10),
          //     Baseline(
          //       baseline: 65,
          //       baselineType: TextBaseline.alphabetic,
          //       child: const Text(
          //         '51',
          //         style: TextStyle(
          //           fontSize: 70,
          //           fontWeight: FontWeight.w600,
          //           height: 1,
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 4),
          //     Baseline(
          //       baseline: 70,
          //       baselineType: TextBaseline.alphabetic,
          //       child: const Text(
          //         'km',
          //         style: TextStyle(fontSize: 24, height: 1),
          //       ),
          //     ),
          //   ],
          // ),

          // Progress bar
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          //   child: Column(
          //     children: [
          //       LinearProgressIndicator(
          //         value: 0.55,
          //         minHeight: 8,
          //         backgroundColor: Colors.grey.shade300,
          //         valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
          //       ),
          //       const SizedBox(height: 6),
          //       const Align(
          //         alignment: Alignment.centerLeft,
          //         child: Text('55%', style: TextStyle(fontSize: 14)),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: screenHeight * 0.67,
        child: Stack(
          children: [
            // Map
            ReusableMapWidget(
              initialPosition: _navigationController.currentPosition,
              markers: _navigationController.markers,
              polylines: _navigationController.polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoom: 14.0,
            ),

            // Search bar
            PositionedStationSearchWidget(
              top: 16,
              left: 16,
              right: 16,
              hintText: 'Find swap stations',
              onStationSelected: _onStationSelected,
              controller: _searchController,
              stations: _availableStations,
              currentPosition: _navigationController.currentPosition,
            ),


         


            // Swap Now button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: GoButton(
                onPressed: () {
                  if (_navigationController.destinationPosition != null) {
                    setState(() {
                      _isFullscreenMap = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a destination first."),
                      ),
                    );
                  }
                },
                text: "Swap Now",
                backgroundColor: Color(0xff0A2342),
                textColor: Colors.white,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchLocationNameIfNeeded() {
    final pos = _navigationController.currentPosition;
    if (pos != null) {
      _getAddressFromLatLng(pos.latitude, pos.longitude);
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        setState(() {
          _locationName = _formatPlacemark(place);
        });
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
  }

  String _formatPlacemark(Placemark place) {
    // Prioritize meaningful information first, fallback as needed
    if (place.name != null && place.name!.isNotEmpty) {
      if ((place.locality ?? '').isNotEmpty) {
        return '${place.name}, ${place.locality}';
      } else {
        return place.name!;
      }
    }
    if ((place.locality ?? '').isNotEmpty) return place.locality!;
    if ((place.subAdministrativeArea ?? '').isNotEmpty) return place.subAdministrativeArea!;
    if ((place.administrativeArea ?? '').isNotEmpty) return place.administrativeArea!;
    if ((place.country ?? '').isNotEmpty) return place.country!;
    return 'Current location';
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/station_model.dart';
import '../services/map_service.dart';

class StationSearchWidget extends StatefulWidget {
  final String hintText;
  final Function(Station) onStationSelected;
  final TextEditingController? controller;
  final List<Station> stations;
  final LatLng? currentPosition;

  const StationSearchWidget({
    super.key,
    this.hintText = 'Search stations',
    required this.onStationSelected,
    this.controller,
    required this.stations,
    this.currentPosition,
  });

  @override
  State<StationSearchWidget> createState() => _StationSearchWidgetState();
}

class _StationSearchWidgetState extends State<StationSearchWidget> {
  late TextEditingController _controller;
  List<_StationWithDistance> _filteredStations = [];
  Timer? _debounce;
  final MapService _mapService = MapService();
  bool _showSuggestions = false; // Track if user has tapped the search bar

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(StationSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered stations when stations or current position changes
    if (_showSuggestions && 
        (oldWidget.stations != widget.stations || 
         oldWidget.currentPosition != widget.currentPosition)) {
      _filterStations(_controller.text);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _filterStations(String query) {
    final currentPos = widget.currentPosition;
    
    List<_StationWithDistance> stationsWithDistance = widget.stations.map((station) {
      double? distance;
      if (currentPos != null) {
        distance = _mapService.calculateDistance(
          currentPos.latitude,
          currentPos.longitude,
          station.position.latitude,
          station.position.longitude,
        );
      }
      return _StationWithDistance(station: station, distance: distance);
    }).toList();

    // Filter by search query if provided
    if (query.isNotEmpty) {
      stationsWithDistance = stationsWithDistance.where((stationWithDist) {
        final station = stationWithDist.station;
        final searchLower = query.toLowerCase();
        return station.name.toLowerCase().contains(searchLower) ||
               station.address.toLowerCase().contains(searchLower) ||
               station.city.toLowerCase().contains(searchLower) ||
               station.code.toLowerCase().contains(searchLower);
      }).toList();
    }

    // Sort by distance (nearest first)
    stationsWithDistance.sort((a, b) {
      if (a.distance == null && b.distance == null) return 0;
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });

    setState(() {
      // Show top 10 nearest stations
      _filteredStations = stationsWithDistance.take(10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search TextField
        TextField(
          controller: _controller,
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 300),
              () {
                if (_showSuggestions) {
                  _filterStations(value);
                }
              },
            );
          },
          onTap: () {
            // Show nearest stations when user taps on search field
            setState(() {
              _showSuggestions = true;
            });
            _filterStations(_controller.text);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _filteredStations = [];
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        // Autocomplete Suggestions List (only show when user tapped search bar)
        if (_showSuggestions && _filteredStations.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(
              maxHeight: 300, // Limit height for scrolling
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _filteredStations.length,
              itemBuilder: (context, index) {
                final stationWithDist = _filteredStations[index];
                final station = stationWithDist.station;
                final distance = stationWithDist.distance;
                
                return ListTile(
                  leading: Icon(
                    Icons.ev_station,
                    color: station.availableSlots > 0 
                        ? Colors.green 
                        : Colors.red,
                  ),
                  title: Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${station.address}, ${station.city}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (distance != null) ...[
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${distance.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            Icons.battery_charging_full,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${station.availableSlots}/${station.capacity} slots',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    widget.onStationSelected(station);
                    _controller.text = station.name;
                    setState(() {
                      _filteredStations = [];
                      _showSuggestions = false;
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Helper class to store station with calculated distance
class _StationWithDistance {
  final Station station;
  final double? distance;

  _StationWithDistance({
    required this.station,
    this.distance,
  });
}

/// Positioned search widget for overlaying on maps
class PositionedStationSearchWidget extends StatelessWidget {
  final double top;
  final double left;
  final double right;
  final String hintText;
  final Function(Station) onStationSelected;
  final TextEditingController? controller;
  final List<Station> stations;
  final LatLng? currentPosition;

  const PositionedStationSearchWidget({
    super.key,
    required this.top,
    required this.left,
    required this.right,
    this.hintText = 'Search stations',
    required this.onStationSelected,
    this.controller,
    required this.stations,
    this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: StationSearchWidget(
        hintText: hintText,
        onStationSelected: onStationSelected,
        controller: controller,
        stations: stations,
        currentPosition: currentPosition,
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/station/station_bloc.dart';
import 'package:swap_app/bloc/station/station_event.dart';
import 'package:swap_app/bloc/station/station_state.dart';
import 'package:swap_app/repo/station_repository.dart';

class TestStationApiScreen extends StatelessWidget {
  const TestStationApiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StationBloc(StationRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test Station API'),
          backgroundColor: Colors.blue,
        ),
        body: BlocBuilder<StationBloc, StationState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Station API Test',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: () {
                      context.read<StationBloc>().add( LoadStations());
                    },
                    child: const Text('Test Load Stations'),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (state is StationLoading)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading stations...'),
                        ],
                      ),
                    )
                  else if (state is StationLoaded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ Success! Loaded ${state.stations.length} stations',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.stations.length,
                              itemBuilder: (context, index) {
                                final station = state.stations[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(station.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${station.city}, ${station.country}'),
                                        Text('${station.availableSlots}/${station.capacity} slots available'),
                                        if (station.operatingHours != null)
                                          Text(
                                            'Hours: ${station.operatingHours.toString()}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                    trailing: station.is24x7 
                                        ? const Icon(Icons.access_time, color: Colors.green)
                                        : const Icon(Icons.schedule, color: Colors.orange),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (state is StationError)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'API Error',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<StationBloc>().add( LoadStations());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      'Press the button to test the station API',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

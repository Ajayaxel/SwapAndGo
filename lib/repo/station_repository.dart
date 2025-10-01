// repository/station_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/station_model.dart';

class StationRepository {
  final String baseUrl = "https://onecharge.io/api/stations";

  Future<List<Station>> fetchStations({
    String? search,
    String? status,
    String? city,
    String? is24x7,
    String? isActive,
    int perPage = 15,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'search': search ?? '',
        'status': status ?? '',
        'city': city ?? '',
        'is_24_7': is24x7 ?? '',
        'is_active': isActive ?? '',
        'per_page': perPage.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Check if the API response is successful
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final List data = jsonData['data']['data'];
        return data.map((station) => Station.fromJson(station)).toList();
      } else {
        throw Exception(jsonData['message'] ?? "Failed to load stations");
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: Failed to load stations");
    }
  }

  /// Fetch station by ID
  Future<Station> fetchStationById(String id) async {
    final uri = Uri.parse("$baseUrl/$id");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      if (jsonData['success'] == true && jsonData['data'] != null) {
        return Station.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message'] ?? "Failed to load station");
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: Failed to load station");
    }
  }
}

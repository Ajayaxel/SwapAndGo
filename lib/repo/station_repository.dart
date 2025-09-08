// repository/station_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swap_app/model/station_model.dart';


class StationRepository {
  final String baseUrl = "https://onecharge.io/api/stations?search=&status=&city=&is_24_7=&is_active=&per_page=15";

  Future<List<Station>> fetchStations() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List data = jsonData['data']['data']; // nested inside "data"
      return data.map((station) => Station.fromJson(station)).toList();
    } else {
      throw Exception("Failed to load stations");
    }
  }
}

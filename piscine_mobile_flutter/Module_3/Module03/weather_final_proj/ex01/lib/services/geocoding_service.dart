
// services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String _baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<Map<String, dynamic>>> fetchCoordinatesByCityName(String cityName, {int count = 10, String language = 'en'}) async {
    final response = await http.get(Uri.parse('$_baseUrl?name=$cityName&count=$count&language=$language'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['results'];
      return data.map((city) => {
        'name': city['name'],
        'latitude': city['latitude'],
        'longitude': city['longitude'],
        'country': city['country'],
        'region': city['admin1']
      }).toList();
    } else {
      throw Exception('Failed to load coordinates');
    }
  }
}

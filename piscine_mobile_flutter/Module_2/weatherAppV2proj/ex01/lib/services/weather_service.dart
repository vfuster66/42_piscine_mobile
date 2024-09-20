
// services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiUrl = 'https://api.open-meteo.com/v1/forecast';
  final String geocodeUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  Future<Map<String, dynamic>> getWeather(double latitude, double longitude) async {
    final url = '$apiUrl?latitude=$latitude&longitude=$longitude&current_weather=true&hourly=temperature_2m,precipitation&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération de la météo : ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API météo : $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCitySuggestions(String cityName) async {
    final url = '$geocodeUrl?name=$cityName';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'] is List) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          return [];
        }
      } else {
        throw Exception('Erreur lors de la récupération des suggestions de villes : ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'API de géocodage : $e');
    }
  }
}


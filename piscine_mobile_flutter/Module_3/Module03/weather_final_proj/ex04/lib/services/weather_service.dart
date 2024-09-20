
// services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/material.dart';

class WeatherService {
  final String apiUrl = 'https://api.open-meteo.com/v1/forecast';
  final String geocodeUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  Future<Map<String, dynamic>> getWeather(double latitude, double longitude) async {
    try {
      final url = '$apiUrl?latitude=$latitude&longitude=$longitude&current_weather=true&hourly=temperature_2m,precipitation,weathercode,windspeed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode&timezone=auto';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération de la météo : ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Impossible de se connecter à l\'API météo. Vérifiez votre connexion Internet.');
    }
  }

  Future<List<Map<String, dynamic>>> getCitySuggestions(String cityName) async {
    try {
      final url = '$geocodeUrl?name=$cityName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'] is List) {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          return [];
        }
      } else {
        throw Exception('Erreur lors de la récupération des coordonnées : ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Impossible de se connecter à l\'API de géocodage. Vérifiez votre connexion Internet.');
    }
  }

  String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing rime fog';
      case 51:
        return 'Drizzle: Light intensity';
      case 53:
        return 'Drizzle: Moderate intensity';
      case 55:
        return 'Drizzle: Dense intensity';
      case 61:
        return 'Rain: Slight intensity';
      case 63:
        return 'Rain: Moderate intensity';
      case 65:
        return 'Rain: Heavy intensity';
      case 71:
        return 'Snow fall: Slight intensity';
      case 73:
        return 'Snow fall: Moderate intensity';
      case 75:
        return 'Snow fall: Heavy intensity';
      case 80:
        return 'Rain showers: Slight';
      case 81:
        return 'Rain showers: Moderate';
      case 82:
        return 'Rain showers: Violent';
      default:
        return 'Unknown weather';
    }
  }

  IconData getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return WeatherIcons.day_sunny;
      case 1:
      case 2:
        return WeatherIcons.day_cloudy;
      case 3:
        return WeatherIcons.cloudy;
      case 45:
      case 48:
        return WeatherIcons.fog;
      case 51:
      case 53:
      case 55:
        return WeatherIcons.showers;
      case 61:
      case 63:
      case 65:
        return WeatherIcons.rain;
      case 71:
      case 73:
      case 75:
        return WeatherIcons.snow;
      case 80:
      case 81:
      case 82:
        return WeatherIcons.thunderstorm;
      default:
        return WeatherIcons.na;
    }
  }
}

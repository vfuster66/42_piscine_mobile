
//screens/currently_screen.dart

import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class CurrentlyScreen extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final String cityName;
  final String region;
  final String country;

  const CurrentlyScreen({
    super.key,
    required this.weatherData,
    required this.cityName,
    required this.region,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final weatherService = WeatherService();
    final locationParts = [
      if (cityName.isNotEmpty) cityName,
      if (region.isNotEmpty) region,
      if (country.isNotEmpty) country,
    ];
    final locationText = locationParts.join(', ');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              locationText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          if (cityName.isEmpty && region.isEmpty && country.isEmpty)
            Center(
              child: Text(
                'Lat: ${weatherData['latitude']}, Lon: ${weatherData['longitude']}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Current Temperature: ${weatherData['current_weather']['temperature']}°C',
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            'Weather: ${weatherService.getWeatherDescription(weatherData['current_weather']['weathercode'])}',
            style: const TextStyle(fontSize: 20),
          ),
          Icon(weatherService.getWeatherIcon(weatherData['current_weather']['weathercode']), size: 48),
          Text(
            'Wind Speed: ${weatherData['current_weather']['windspeed']} km/h',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

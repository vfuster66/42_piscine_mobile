
// screens/currently_screen.dart
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

  String formatLocation(String cityName, String region, String country) {
    // Créer une liste avec le nom de la ville, la région (si elle existe), et le pays
    final locationParts = [
      if (cityName.isNotEmpty) cityName,
      if (region.isNotEmpty) region, // Ne rajoute la région que si elle n'est pas vide
      if (country.isNotEmpty) country,
    ];

    // Joindre les parties non vides avec une virgule et un espace
    return locationParts.join(', ');
  }


  @override
  Widget build(BuildContext context) {
    final weatherService = WeatherService();
    final locationParts = [
      if (cityName.isNotEmpty) cityName,
      if (region.isNotEmpty) region,
      if (country.isNotEmpty) country,
    ];
    final locationText = locationParts.join(', ');

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/blue-sky-background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                cityName.isEmpty && region.isEmpty && country.isEmpty
                    ? 'Lat: ${weatherData['latitude']}, Lon: ${weatherData['longitude']}'
                    : formatLocation(cityName, region, country),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

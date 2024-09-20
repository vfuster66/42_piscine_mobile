

import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class WeeklyScreen extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final String cityName;
  final String region;
  final String country;

  const WeeklyScreen({
    super.key,
    required this.weatherData,
    required this.cityName,
    required this.region,
    required this.country,
  });

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('EEEE, MMM d').format(dateTime);
  }

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
    if (weatherData.isEmpty) {
      return const Center(child: Text('No weather data available.'));
    }

    final weatherService = WeatherService();
    final dailyData = weatherData['daily'] ?? {};
    final times = dailyData['time'] ?? [];
    final minTemperatures = dailyData['temperature_2m_min'] ?? [];
    final maxTemperatures = dailyData['temperature_2m_max'] ?? [];
    final weatherCodes = dailyData['weathercode'] ?? [];

    if (times.isEmpty) {
      return const Center(child: Text('No daily weather data available.'));
    }

    PageController pageController = PageController(initialPage: 0);

    List<Widget> dailyWeather = [];
    for (int i = 0; i < times.length; i++) {
      dailyWeather.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatDate(times[i]),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Min Temperature: ${i < minTemperatures.length ? minTemperatures[i] : 'N/A'}°C',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              Text(
                'Max Temperature: ${i < maxTemperatures.length ? maxTemperatures[i] : 'N/A'}°C',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              Text(
                'Weather: ${i < weatherCodes.length ? weatherService.getWeatherDescription(weatherCodes[i]) : 'Unknown'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              Icon(
                i < weatherCodes.length ? weatherService.getWeatherIcon(weatherCodes[i]) : WeatherIcons.na,
                size: 48,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
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
            child: PageView.builder(
              controller: pageController,
              itemCount: dailyWeather.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return dailyWeather[index];
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

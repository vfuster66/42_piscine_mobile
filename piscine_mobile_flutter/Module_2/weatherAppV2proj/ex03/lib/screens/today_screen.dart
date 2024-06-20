import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class TodayScreen extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final String cityName;
  final String region;
  final String country;

  const TodayScreen({
    super.key,
    required this.weatherData,
    required this.cityName,
    required this.region,
    required this.country,
  });

  String formatTime(String isoTime) {
    final dateTime = DateTime.parse(isoTime);
    return DateFormat('HH:mm').format(dateTime);
  }

  String formatLocation(String cityName, String region, String country) {
    if (region.isEmpty) {
      return '$cityName, $country';
    }
    return '$cityName, $region, $country';
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData.isEmpty) {
      return const Center(child: Text('No weather data available.'));
    }

    final weatherService = WeatherService();
    final hourlyData = weatherData['hourly'] ?? {};
    final times = hourlyData['time'] ?? [];
    final temperatures = hourlyData['temperature_2m'] ?? [];
    final weatherCodes = hourlyData['weathercode'] ?? [];
    final windSpeeds = hourlyData['windspeed_10m'] ?? [];

    if (times.isEmpty) {
      return const Center(child: Text('No hourly weather data available.'));
    }

    int currentHour = DateTime.now().hour;
    int startIndex = times.indexWhere((time) => DateTime.parse(time).hour == currentHour);
    if (startIndex == -1) startIndex = 0;

    PageController pageController = PageController(initialPage: startIndex);

    List<Widget> hourlyWeather = [];
    for (int i = 0; i < times.length; i++) {
      hourlyWeather.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hour: ${formatTime(times[i])}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Temperature: ${i < temperatures.length ? temperatures[i] : 'N/A'}°C',
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
              const SizedBox(height: 5),
              Text(
                'Wind Speed: ${i < windSpeeds.length ? windSpeeds[i] : 'N/A'} km/h',
                style: const TextStyle(fontSize: 18),
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
              itemCount: hourlyWeather.length,
              itemBuilder: (context, index) {
                return hourlyWeather[index];
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

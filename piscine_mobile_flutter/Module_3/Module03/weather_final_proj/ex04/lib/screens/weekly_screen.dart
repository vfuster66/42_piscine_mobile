
// screens/weekly_screen.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/weather_service.dart';

class WeeklyScreen extends StatefulWidget {
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

  @override
  WeeklyScreenState createState() => WeeklyScreenState();
}

class WeeklyScreenState extends State<WeeklyScreen> {
  bool _showChart = false;
  final PageController _pageController = PageController();

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('EEE').format(dateTime); // format to show day of the week
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
    if (widget.weatherData.isEmpty) {
      return const Center(child: Text('No weather data available.'));
    }

    final weatherService = WeatherService();
    final dailyData = widget.weatherData['daily'] ?? {};
    final times = dailyData['time'] ?? [];
    final minTemperatures = dailyData['temperature_2m_min'] ?? [];
    final maxTemperatures = dailyData['temperature_2m_max'] ?? [];
    final weatherCodes = dailyData['weathercode'] ?? [];

    if (times.isEmpty) {
      return const Center(child: Text('No daily weather data available.'));
    }

    List<Widget> dailyWeather = [];
    for (int i = 0; i < times.length; i++) {
      dailyWeather.add(
        Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding to lift up the list items
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatDate(times[i]),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5), // Reduced spacing
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

    List<DailyTemperature> minTemperatureData = List.generate(times.length, (index) {
      return DailyTemperature(DateTime.parse(times[index]), minTemperatures[index]);
    });

    List<DailyTemperature> maxTemperatureData = List.generate(times.length, (index) {
      return DailyTemperature(DateTime.parse(times[index]), maxTemperatures[index]);
    });

    // Create plot bands for Tuesday, Thursday, and Saturday
    List<PlotBand> plotBands = times.map((time) {
      final date = DateTime.parse(time);
      final weekday = date.weekday;
      if (weekday == DateTime.tuesday || weekday == DateTime.thursday || weekday == DateTime.saturday) {
        return PlotBand(
          start: date,
          end: date,
          borderColor: Colors.grey,
          borderWidth: 1,
        );
      }
      return null;
    }).where((band) => band != null).toList().cast<PlotBand>();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/blue-sky-background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // This ensures the background image is visible
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_showChart ? Icons.list : Icons.show_chart),
              onPressed: () {
                setState(() {
                  _showChart = !_showChart;
                });
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8), // Reduced spacing
            Center(
              child: Text(
                widget.cityName.isEmpty && widget.region.isEmpty && widget.country.isEmpty
                    ? 'Lat: ${widget.weatherData['latitude']}, Lon: ${widget.weatherData['longitude']}'
                    : formatLocation(widget.cityName, widget.region, widget.country),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8), // Reduced spacing
            Expanded(
              child: _showChart
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat.E(),
                    intervalType: DateTimeIntervalType.days,
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    plotBands: plotBands,
                  ),
                  primaryYAxis: const NumericAxis(
                    labelFormat: '{value}°C',
                    minimum: 0,
                    maximum: 40,
                  ),
                  series: <CartesianSeries>[
                    LineSeries<DailyTemperature, DateTime>(
                      dataSource: minTemperatureData,
                      xValueMapper: (DailyTemperature temp, _) => temp.date,
                      yValueMapper: (DailyTemperature temp, _) => temp.temperature,
                      color: Colors.blue,
                      width: 2,
                      markerSettings: const MarkerSettings(isVisible: false),
                      dataLabelSettings: const DataLabelSettings(isVisible: false),
                    ),
                    LineSeries<DailyTemperature, DateTime>(
                      dataSource: maxTemperatureData,
                      xValueMapper: (DailyTemperature temp, _) => temp.date,
                      yValueMapper: (DailyTemperature temp, _) => temp.temperature,
                      color: Colors.red,
                      width: 2,
                      markerSettings: const MarkerSettings(isVisible: false),
                      dataLabelSettings: const DataLabelSettings(isVisible: false),
                    ),
                  ],
                ),
              )
                  : PageView.builder(
                controller: _pageController,
                itemCount: dailyWeather.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return dailyWeather[index];
                },
              ),
            ),
            if (!_showChart)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class DailyTemperature {
  final DateTime date;
  final double temperature;

  DailyTemperature(this.date, this.temperature);
}

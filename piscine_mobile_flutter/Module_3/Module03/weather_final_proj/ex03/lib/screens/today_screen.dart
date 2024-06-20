import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import '../services/weather_service.dart';

class TodayScreen extends StatefulWidget {
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

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _showChart = false;

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
    if (widget.weatherData.isEmpty) {
      return const Center(child: Text('No weather data available.'));
    }

    final weatherService = WeatherService();
    final hourlyData = widget.weatherData['hourly'] ?? {};
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

    List<HourlyTemperature> temperatureData = List.generate(times.length, (index) {
      return HourlyTemperature(DateTime.parse(times[index]), temperatures[index]);
    });

    final now = DateTime.now();

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
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.cityName.isEmpty && widget.region.isEmpty && widget.country.isEmpty
                    ? 'Lat: ${widget.weatherData['latitude']}, Lon: ${widget.weatherData['longitude']}'
                    : formatLocation(widget.cityName, widget.region, widget.country),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _showChart
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width, // Adjusted width to fit screen width
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat.Hm(),
                        intervalType: DateTimeIntervalType.hours,
                        minimum: DateTime(now.year, now.month, now.day, 0, 0),
                        maximum: DateTime(now.year, now.month, now.day, 23, 59),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        plotBands: <PlotBand>[
                          PlotBand(
                            start: now,
                            end: now,
                            borderColor: Colors.red,
                            borderWidth: 2,
                          ),
                        ],
                      ),
                      primaryYAxis: NumericAxis(
                        labelFormat: '{value}°C',
                        minimum: 0,
                        maximum: 40,
                      ),
                      series: <CartesianSeries>[
                        LineSeries<HourlyTemperature, DateTime>(
                          dataSource: temperatureData,
                          xValueMapper: (HourlyTemperature temp, _) => temp.time,
                          yValueMapper: (HourlyTemperature temp, _) => temp.temperature,
                          color: Colors.blue,
                          width: 2,
                          markerSettings: const MarkerSettings(isVisible: false),
                          dataLabelSettings: const DataLabelSettings(isVisible: false),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : PageView.builder(
                controller: pageController,
                itemCount: hourlyWeather.length,
                itemBuilder: (context, index) {
                  return hourlyWeather[index];
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
      ),
    );
  }
}

class HourlyTemperature {
  final DateTime time;
  final double temperature;

  HourlyTemperature(this.time, this.temperature);
}

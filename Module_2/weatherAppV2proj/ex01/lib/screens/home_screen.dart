import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_icons/weather_icons.dart'; // Import the weather icons package
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/top_bar.dart';
import 'currently_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _locationMessage = '';
  String _selectedCityName = '';
  Map<String, dynamic>? _weatherData;
  List<Map<String, dynamic>> _citySuggestions = [];

  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService(); // Instance of the location service
  final WeatherService _weatherService = WeatherService(); // Instance of the weather service

  static const List<Widget> _widgetOptions = <Widget>[
    CurrentlyScreen(key: PageStorageKey('CurrentlyScreen')),
    TodayScreen(key: PageStorageKey('TodayScreen')),
    WeeklyScreen(key: PageStorageKey('WeeklyScreen')),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _onSearch(_searchController.text);
    } else {
      setState(() {
        _citySuggestions = [];
      });
    }
  }

  void _onSearch(String searchText) async {
    try {
      List<Map<String, dynamic>> suggestions = await _weatherService.getCitySuggestions(searchText);
      setState(() {
        _citySuggestions = suggestions;
      });
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
    }
  }

  void _selectCity(String cityName, double latitude, double longitude) {
    setState(() {
      _citySuggestions = [];
      _selectedCityName = cityName;
      _searchController.clear();
      _locationMessage = ''; // Clear the location message
      _weatherData = null; // Clear the previous weather data
    });
    _getWeather(latitude, longitude);
  }

  void _onGeolocate() async {
    _showLocationAccuracyDialog();
  }

  void _showLocationAccuracyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisissez la précision de la localisation'),
          content: const Text('Veuillez choisir la précision souhaitée pour la localisation.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _determinePosition(LocationAccuracy.low);
                Navigator.of(context).pop();
              },
              child: const Text('Approximate'),
            ),
            TextButton(
              onPressed: () {
                _determinePosition(LocationAccuracy.high);
                Navigator.of(context).pop();
              },
              child: const Text('Precise'),
            ),
          ],
        );
      },
    );
  }

  void _determinePosition(LocationAccuracy accuracy) async {
    try {
      Position position = await _locationService.determinePosition(accuracy: accuracy);
      setState(() {
        _locationMessage = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
        _selectedCityName = ''; // Clear the city name
        _searchController.clear(); // Clear the search controller
        _weatherData = null; // Clear the previous weather data
      });
      print(_locationMessage); // Log the location

      _getWeather(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
      print(_locationMessage); // Log the error
    }
  }

  void _getWeather(double latitude, double longitude) async {
    try {
      Map<String, dynamic> weatherData = await _weatherService.getWeather(latitude, longitude);
      setState(() {
        _weatherData = weatherData;
      });
      print(weatherData); // Log the weather data
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
      print(_locationMessage); // Log the error
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        searchController: _searchController,
        onSearch: _onSearch,
        onGeolocate: _onGeolocate,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _widgetOptions.elementAt(_selectedIndex),
            if (_selectedCityName.isNotEmpty) Text(_selectedCityName), // Display the full name of the selected city
            if (_locationMessage.isNotEmpty) Text(_locationMessage),
            if (_citySuggestions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _citySuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _citySuggestions[index];
                    return ListTile(
                      title: Text('${suggestion['name']}, ${suggestion['country']}'),
                      onTap: () {
                        _selectCity('${suggestion['name']}, ${suggestion['country']}', suggestion['latitude'], suggestion['longitude']);
                      },
                    );
                  },
                ),
              ),
            if (_weatherData != null)
              Column(
                children: [
                  Text('Température actuelle : ${_weatherData!['current_weather']['temperature']} °C'),
                  Icon(getWeatherIcon(_weatherData!['current_weather']['weathercode'])), // Display weather icon
                  Text('Vitesse du vent : ${_weatherData!['current_weather']['windspeed']} km/h'),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

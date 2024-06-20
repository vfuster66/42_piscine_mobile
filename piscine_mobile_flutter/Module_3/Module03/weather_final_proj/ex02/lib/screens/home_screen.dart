import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  String _selectedCityName = '';
  String _selectedRegion = '';
  String _selectedCountry = '';
  String _errorMessage = '';
  Map<String, dynamic>? _weatherData;
  List<Map<String, dynamic>> _citySuggestions = [];

  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

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

  void _onSearchChanged() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _errorMessage = '';
        _citySuggestions = [];
      });
    } else {
      try {
        List<Map<String, dynamic>> suggestions = await _weatherService.getCitySuggestions(_searchController.text);
        setState(() {
          _citySuggestions = suggestions;
          _errorMessage = ''; // Clear the error message on successful search
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to connect to the API, check your connection';
          _citySuggestions = [];
        });
      }
    }
  }

  void _onSearch(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    try {
      List<Map<String, dynamic>> suggestions = await _weatherService.getCitySuggestions(searchText);
      if (suggestions.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid city name, try again';
          _citySuggestions = [];
        });
      } else {
        setState(() {
          _citySuggestions = suggestions;
          _errorMessage = ''; // Clear the error message on successful search
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to the API, check your connection';
        _citySuggestions = [];
      });
    }
  }

  void _selectCity(String cityName, String? region, String country, double latitude, double longitude) {
    setState(() {
      _citySuggestions = [];
      _selectedCityName = cityName;
      _selectedRegion = region ?? '';
      _selectedCountry = country;
      _searchController.clear();
      _errorMessage = '';
      _weatherData = null;
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
          title: const Text('Choose location accuracy'),
          content: const Text('Please choose the desired location accuracy.'),
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
        _selectedCityName = '';
        _selectedRegion = '';
        _selectedCountry = '';
        _searchController.clear();
        _weatherData = null;
        _errorMessage = '';
      });

      _getWeather(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to determine position, please try again';
      });
    }
  }

  void _getWeather(double latitude, double longitude) async {
    try {
      Map<String, dynamic> weatherData = await _weatherService.getWeather(latitude, longitude);
      setState(() {
        _weatherData = weatherData;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to retrieve weather data, check your connection';
      });
    }
  }

  Widget _buildCurrentScreen() {
    return CurrentlyScreen(
      weatherData: _weatherData!,
      cityName: _selectedCityName,
      region: _selectedRegion,
      country: _selectedCountry,
    );
  }

  Widget _buildTodayScreen() {
    return TodayScreen(
      weatherData: _weatherData!,
      cityName: _selectedCityName,
      region: _selectedRegion,
      country: _selectedCountry,
    );
  }

  Widget _buildWeeklyScreen() {
    return WeeklyScreen(
      weatherData: _weatherData!,
      cityName: _selectedCityName,
      region: _selectedRegion,
      country: _selectedCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        searchController: _searchController,
        onSearch: _onSearch,
        onGeolocate: _onGeolocate,
        citySuggestions: _citySuggestions,
        onSelectCity: _selectCity,
        height: 80, // Set the height of the TopBar to 80
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/blue-sky-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              Expanded(
                child: _weatherData == null
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedIndex == 0
                    ? _buildCurrentScreen()
                    : _selectedIndex == 1
                    ? _buildTodayScreen()
                    : _buildWeeklyScreen(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

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
        _selectedCityName = '';
        _selectedRegion = '';
        _selectedCountry = '';
        _searchController.clear();
        _weatherData = null;
      });

      _getWeather(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
      });
    }
  }

  void _getWeather(double latitude, double longitude) async {
    try {
      Map<String, dynamic> weatherData = await _weatherService.getWeather(latitude, longitude);
      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      setState(() {
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_weatherData != null)
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 200, // Ajuster la hauteur disponible
                          child: _selectedIndex == 0
                              ? _buildCurrentScreen()
                              : _selectedIndex == 1
                              ? _buildTodayScreen()
                              : _buildWeeklyScreen(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_citySuggestions.isNotEmpty)
              SizedBox(
                height: 200, // Ajuster la hauteur du conteneur pour les suggestions
                child: ListView.builder(
                  itemCount: _citySuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _citySuggestions[index];
                    final region = suggestion['region'];
                    final cityDisplayName = region != null && region.isNotEmpty
                        ? '${suggestion['name']}, $region, ${suggestion['country']}'
                        : '${suggestion['name']}, ${suggestion['country']}';
                    return ListTile(
                      title: Text(cityDisplayName),
                      onTap: () {
                        _selectCity(
                          suggestion['name'],
                          region,
                          suggestion['country'],
                          suggestion['latitude'],
                          suggestion['longitude'],
                        );
                      },
                    );
                  },
                ),
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

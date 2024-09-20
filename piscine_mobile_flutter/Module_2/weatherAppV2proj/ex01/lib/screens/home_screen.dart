

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_icons/weather_icons.dart';
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
  String _errorMessage = ''; // New variable for error message

  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService(); // Instance of the location service
  final WeatherService _weatherService = WeatherService(); // Instance of the weather service
  final PageController _pageController = PageController(); // PageController for swiping

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
    _pageController.dispose(); // Dispose PageController
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Navigate to the selected page
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _onSearch(_searchController.text);
    } else {
      setState(() {
        _citySuggestions = [];
        _errorMessage = ''; // Clear the error message when the search text is empty
      });
    }
  }

  void _onSearch(String searchText) async {
    try {
      List<Map<String, dynamic>> suggestions = await _weatherService.getCitySuggestions(searchText);
      if (suggestions.isEmpty) {
        setState(() {
          _errorMessage = "Aucune ville trouvée."; // Display error if no cities are found
        });
      } else {
        setState(() {
          _citySuggestions = suggestions;
          _errorMessage = ''; // Clear error message if there are suggestions
        });
      }
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
      _errorMessage = ''; // Clear error message when a city is selected
    });
    _getWeather(latitude, longitude);
  }

  void _onSearchSubmitted() {
    if (_citySuggestions.isNotEmpty) {
      final firstSuggestion = _citySuggestions.first;
      _selectCity(
        '${firstSuggestion['name']}, ${firstSuggestion['country']}',
        firstSuggestion['latitude'],
        firstSuggestion['longitude'],
      );
    }
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
      // Obtenir la position actuelle
      Position position = await _locationService.determinePosition(accuracy: accuracy);

      // Récupérer le nom de la ville via le reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      // Vérification que la liste des placemarks n'est pas vide et que le champ locality n'est pas null
      String cityName = (placemarks.isNotEmpty && placemarks.first.locality != null)
          ? placemarks.first.locality!
          : 'Ville inconnue'; // Fallback si le reverse geocoding ne trouve pas la ville


      setState(() {
        _locationMessage = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
        _selectedCityName = cityName;
        _searchController.clear();
        _weatherData = null;
      });

      // Appel de la fonction pour obtenir les informations météo en fonction de la position
      _getWeather(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
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
        _locationMessage = e.toString();
      });
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
        onSearchSubmitted: _onSearchSubmitted,
        onGeolocate: _onGeolocate,
      ),
      body: Column(
        children: [
          // Affichage des suggestions de ville sous la barre de recherche
          if (_citySuggestions.isNotEmpty)
            SizedBox(
              height: 150, // Taille définie pour la liste des suggestions
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

          // Affichage du reste du contenu
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: _widgetOptions,
                ),

                if (_weatherData != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Centre verticalement le contenu
                        children: [
                          // Affichage du nom de la ville sélectionnée
                          if (_selectedCityName.isNotEmpty)
                            Text(
                              _selectedCityName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Affichage des coordonnées GPS
                          if (_locationMessage.isNotEmpty)
                            Text(
                              _locationMessage, // Affiche la latitude et la longitude
                              style: const TextStyle(fontSize: 18),
                            ),
                          const SizedBox(height: 8),

                          // Affichage des informations météo
                          Text(
                            'Température actuelle : ${_weatherData!['current_weather']['temperature']} °C',
                            style: const TextStyle(fontSize: 24),
                          ),
                          Icon(
                            getWeatherIcon(_weatherData!['current_weather']['weathercode']),
                            size: 64,
                          ),
                          Text(
                            'Vitesse du vent : ${_weatherData!['current_weather']['windspeed']} km/h',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

}

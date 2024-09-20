
// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  String _errorMessage = '';
  String _locationMessage = '';

  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _onSearch(_searchController.text);
    } else {
      setState(() {
        _citySuggestions = [];
        _errorMessage = '';
      });
    }
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

  void _onSearch(String searchText) async {
    try {
      List<Map<String, dynamic>> suggestions = await _weatherService
          .getCitySuggestions(searchText);
      if (suggestions.isEmpty) {
        setState(() {
          _errorMessage =
          "Aucune ville trouvée."; // Display error if no cities are found
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

  void _selectCity(String cityName, double latitude, double longitude, {String? region, String? country}) {
    setState(() {
      _citySuggestions = [];
      _selectedCityName = cityName;
      _searchController.clear();
      _locationMessage = ''; // Clear the location message
      _weatherData = null; // Clear the previous weather data
      _errorMessage = ''; // Clear error message when a city is selected

      // Met à jour la région et le pays seulement s'ils sont valides
      if (region != null && region.isNotEmpty) {
        _selectedRegion = region;
      } else {
        _selectedRegion = ''; // Pas de région si elle n'est pas trouvée
      }

      if (country != null && country.isNotEmpty) {
        _selectedCountry = country;
      } else {
        _selectedCountry = ''; // Pas de pays si non trouvé
      }
    });

    // Obtenir la météo avec les nouvelles coordonnées
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
          content: const Text(
              'Veuillez choisir la précision souhaitée pour la localisation.'),
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

      // Récupérer le nom de la ville, la région et le pays via le reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String cityName = placemark.locality ?? 'Ville inconnue';
        String country = placemark.country ?? 'Pays inconnu';
        String region = placemark.administrativeArea ?? 'Région inconnue';

        setState(() {
          _locationMessage = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
          _selectedCityName = cityName;
          _weatherData = null;
          _selectedRegion = region;
          _selectedCountry = country;
          _searchController.clear();
        });

        // Appeler la fonction pour obtenir les informations météo en fonction de la position
        _getWeather(position.latitude, position.longitude);
      }
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
    }
  }

  void _getWeather(double latitude, double longitude) async {
    try {
      Map<String, dynamic> weatherData = await _weatherService.getWeather(
          latitude, longitude);

      setState(() {
        _weatherData = weatherData;
      });
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
    }
  }

  Widget _buildCurrentScreen() {
    if (_weatherData != null) {
      return CurrentlyScreen(
        weatherData: _weatherData!,
        cityName: _selectedCityName,
        region: _selectedRegion,
        country: _selectedCountry,
      );
    } else {
      return const Center(child: Text("Chargement des données météo..."));
    }
  }

  Widget _buildTodayScreen() {
    if (_weatherData != null) {
      return TodayScreen(
        weatherData: _weatherData!,
        cityName: _selectedCityName,
        region: _selectedRegion,
        country: _selectedCountry,
      );
    } else {
      return const Center(child: Text("Chargement des données météo..."));
    }
  }

  Widget _buildWeeklyScreen() {
    if (_weatherData != null) {
      return WeeklyScreen(
        weatherData: _weatherData!,
        cityName: _selectedCityName,
        region: _selectedRegion,
        country: _selectedCountry,
      );
    } else {
      return const Center(child: Text("Chargement des données météo..."));
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
        citySuggestions: _citySuggestions,
        onSelectCity: (String cityName, String? region, String country,
            double latitude, double longitude) {
          _selectCity(cityName, latitude, longitude);
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Ajoute un borderRadius à la BoxDecoration
          image: const DecorationImage(
            image: AssetImage('assets/blue-sky-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            children: [
              // Si des suggestions de ville existent, elles s'affichent ici sous la barre de recherche
              if (_citySuggestions.isNotEmpty)
                SizedBox(
                  height: 200,
                  // Ajuster la hauteur du conteneur pour les suggestions
                  child: ListView.builder(
                    itemCount: _citySuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _citySuggestions[index];
                      final region = suggestion['region'];
                      final cityDisplayName = region != null &&
                          region.isNotEmpty
                          ? '${suggestion['name']}, $region, ${suggestion['country']}'
                          : '${suggestion['name']}, ${suggestion['country']}';
                      return ListTile(
                        title: Text(cityDisplayName),
                        onTap: () {
                          _selectCity(
                            '${suggestion['name']}, ${suggestion['country']}',
                            suggestion['latitude'],
                            suggestion['longitude'],
                            region: suggestion['region'],  // Passer la région ici si elle existe
                            country: suggestion['country'],  // Passer le pays ici
                          );
                        },
                      );
                    },
                  ),
                ),
              // La partie principale de la page prend l'espace restant (le PageView)
              Expanded(
                child: PageView(
                  controller: _pageController, // Utiliser un PageController
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex =
                          index; // Mettre à jour l'index sélectionné
                    });
                  },
                  children: [
                    _buildCurrentScreen(), // Écran "Current"
                    _buildTodayScreen(), // Écran "Today"
                    _buildWeeklyScreen(), // Écran "Weekly"
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex =
                index; // Mise à jour de l'index lorsque l'utilisateur appuie sur un élément de la barre
          });
          _pageController.jumpToPage(
              index); // Naviguer vers la page correspondante
        },
      ),
    );
  }
}


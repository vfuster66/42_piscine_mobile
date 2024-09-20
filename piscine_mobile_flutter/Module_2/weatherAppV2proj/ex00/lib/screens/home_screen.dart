import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
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
  String _searchText = '';
  String _locationMessage = '';

  final PageController _pageController = PageController(); // Ajout d'un PageController
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  static const List<Widget> _widgetOptions = <Widget>[
    CurrentlyScreen(key: PageStorageKey('CurrentlyScreen')),
    TodayScreen(key: PageStorageKey('TodayScreen')),
    WeeklyScreen(key: PageStorageKey('WeeklyScreen')),
  ];

  // Méthode pour gérer la recherche
  void _onSearch(String searchText) {
    setState(() {
      _searchText = searchText;
    });
  }

  // Méthode pour changer d'onglet via la BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Naviguer vers la page correspondante
  }

  // Méthode pour gérer le swipe entre les pages
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index; // Mettre à jour l'onglet actif lors du swipe
    });
  }

  // Méthode pour gérer la géolocalisation
  void _onGeolocate() async {
    _showLocationAccuracyDialog();
  }

  // Affichage du dialogue pour choisir la précision de la localisation
  void _showLocationAccuracyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Location Accuracy'),
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

  // Méthode pour obtenir la position GPS
  void _determinePosition(LocationAccuracy accuracy) async {
    try {
      Position position = await _locationService.determinePosition(accuracy: accuracy);
      setState(() {
        _locationMessage = 'Lat: ${position.latitude}, Lon: ${position.longitude}'; // Stocker les coordonnées
      });
    } catch (e) {
      setState(() {
        _locationMessage = e.toString(); // Stocker l'erreur si la localisation échoue
      });
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _widgetOptions,
            ),
          ),
          // Affichage de la géolocalisation ou d'un message
          if (_locationMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _locationMessage,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

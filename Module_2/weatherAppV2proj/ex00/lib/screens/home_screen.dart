
// screens/home_screen.dart
// screens/home_screen.dart
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

  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService(); // Instance du service de localisation

  static const List<Widget> _widgetOptions = <Widget>[
    CurrentlyScreen(key: PageStorageKey('CurrentlyScreen')),
    TodayScreen(key: PageStorageKey('TodayScreen')),
    WeeklyScreen(key: PageStorageKey('WeeklyScreen')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSearch(String searchText) {
    setState(() {
      _searchText = searchText;
    });
  }

  void _onGeolocate() async {
    _showLocationAccuracyDialog();
  }

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

  void _determinePosition(LocationAccuracy accuracy) async {
    try {
      Position position = await _locationService.determinePosition(accuracy: accuracy);
      setState(() {
        _locationMessage = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
      });
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _widgetOptions.elementAt(_selectedIndex),
            Text(_searchText),
            if (_locationMessage.isNotEmpty) Text(_locationMessage),
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

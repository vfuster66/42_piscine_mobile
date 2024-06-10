
// screens/home_screen.dart
import 'package:flutter/material.dart';
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

  final TextEditingController _searchController = TextEditingController();

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

  void _onGeolocate() {
    setState(() {
      _searchText = 'Geolocation';
    });
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




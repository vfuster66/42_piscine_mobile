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

  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  List<Widget> get _widgetOptions => [
    CurrentlyScreen(searchText: _searchText),
    TodayScreen(searchText: _searchText),
    WeeklyScreen(searchText: _searchText),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

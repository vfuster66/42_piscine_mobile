// screens/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_bar.dart';
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
  final PageController _pageController = PageController(); // Ajout du PageController

  static const List<Widget> _widgetOptions = <Widget>[
    CurrentlyScreen(),
    TodayScreen(),
    WeeklyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Navigue vers la page correspondante
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // Met à jour la BottomBar lors du swiping
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

import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  final String searchText; // Ajout du texte de recherche

  const TodayScreen({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Today',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            searchText, // Affichage du texte recherché
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

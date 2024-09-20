import 'package:flutter/material.dart';

class CurrentlyScreen extends StatelessWidget {
  final String searchText; // Ajout du texte de recherche

  const CurrentlyScreen({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Currently',
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

import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onGeolocate;
  final VoidCallback onSearchSubmitted; // Ajout de la fonction pour gérer la soumission de recherche

  const TopBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onGeolocate,
    required this.onSearchSubmitted, // Ajout de ce paramètre dans le constructeur
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une ville',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              onSearchSubmitted(); // Appelle la fonction de soumission lorsque le bouton recherche est pressé
            },
          ),
        ),
        onSubmitted: (value) {
          onSearchSubmitted(); // Appelle la fonction de soumission lorsque l'utilisateur appuie sur "Entrée"
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: onGeolocate,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onGeolocate;
  final VoidCallback onSearchSubmitted;

  const TopBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onGeolocate,
    required this.onSearchSubmitted,
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
              onSearchSubmitted();
            }, // Correction ici
          ),
        ),
        onSubmitted: (value) {
          onSearchSubmitted();
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


// widgets/top_bar.dart
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onGeolocate;

  const TopBar({
    required this.searchController,
    required this.onSearch,
    required this.onGeolocate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une ville',
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              onSearch(searchController.text);
            },
          ),
        ),
        onChanged: onSearch,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.location_on),
          onPressed: onGeolocate,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

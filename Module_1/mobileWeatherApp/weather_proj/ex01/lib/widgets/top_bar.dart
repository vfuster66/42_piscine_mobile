
// widgets/top_bar.dart
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function onGeolocate;

  const TopBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onGeolocate,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          suffixIcon: IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              onGeolocate();
            },
          ),
        ),
        onSubmitted: (value) {
          onSearch(value);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}



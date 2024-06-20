import 'package:flutter/material.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onGeolocate;
  final List<Map<String, dynamic>> citySuggestions;
  final Function(String, String?, String, double, double) onSelectCity;

  const TopBar({
    required this.searchController,
    required this.onSearch,
    required this.onGeolocate,
    required this.citySuggestions,
    required this.onSelectCity,
    super.key,
  });

  @override
  TopBarState createState() => TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TopBarState extends State<TopBar> {
  final GlobalKey _searchFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = _searchFieldKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5, // Add some space below the search bar
        width: size.width,
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(10), // Add rounded corners
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10), // Add rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: widget.citySuggestions.length > 5 ? 5 : widget.citySuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = widget.citySuggestions[index];
                final region = suggestion['region'];
                final cityDisplayName = region != null && region.isNotEmpty
                    ? '${suggestion['name']}, $region, ${suggestion['country']}'
                    : '${suggestion['name']}, ${suggestion['country']}';
                return ListTile(
                  title: Text(cityDisplayName),
                  onTap: () {
                    widget.onSelectCity(
                      suggestion['name'],
                      region,
                      suggestion['country'],
                      suggestion['latitude'],
                      suggestion['longitude'],
                    );
                    _hideOverlay();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.citySuggestions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOverlay();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hideOverlay();
      });
    }

    return AppBar(
      title: Container(
        key: _searchFieldKey,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: widget.searchController,
          decoration: InputDecoration(
            hintText: 'Search for a city',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                widget.onSearch(widget.searchController.text);
              },
            ),
          ),
          onChanged: widget.onSearch,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0), // Add padding to move the button to the left
          child: IconButton(
            icon: const Icon(Icons.location_on, size: 32), // Increase the icon size
            onPressed: widget.onGeolocate,
          ),
        ),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}


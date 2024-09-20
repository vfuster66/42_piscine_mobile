
// services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> determinePosition({LocationAccuracy accuracy = LocationAccuracy.high}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifiez si les services de localisation sont activés.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Les services de localisation sont désactivés.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("La permission de localisation est refusée.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("La permission de localisation est définitivement refusée.");
    }

    // Lorsque les permissions sont accordées, nous pouvons obtenir la position de l'appareil.
    return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }
}


import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeofencingService {
  // Define the allowed location boundaries (for example, school coordinates)
  static const double _allowedLatitude = -6.2088; // Example: School latitude
  static const double _allowedLongitude = 106.8456; // Example: School longitude
  static const double _allowedRadius = 100.0; // 100 meters radius
  
  // Check if location services are enabled
  Future<bool> _isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }
  
  // Request location permissions
  Future<LocationPermission> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission;
  }
  
  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await _isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
      
      LocationPermission permission = await _requestLocationPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
  
  // Calculate distance between two coordinates
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  // Check if the user is within the allowed area
  Future<bool> isWithinAllowedArea() async {
    try {
      Position? currentPosition = await getCurrentLocation();
      
      if (currentPosition == null) {
        return false;
      }
      
      double distance = _calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        _allowedLatitude,
        _allowedLongitude,
      );
      
      // Check if the distance is within the allowed radius
      return distance <= _allowedRadius;
    } catch (e) {
      print('Error checking location: $e');
      return false;
    }
  }
  
  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }
  
  // Get current address
  Future<String?> getCurrentAddress() async {
    try {
      Position? currentPosition = await getCurrentLocation();
      
      if (currentPosition == null) {
        return null;
      }
      
      return await getAddressFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );
    } catch (e) {
      print('Error getting current address: $e');
      return null;
    }
  }
  
  // Update allowed area (for admin to set school location)
  void updateAllowedArea(double latitude, double longitude, double radius) {
    // In a real implementation, this would be stored in shared preferences or sent to backend
    // For now, we're just showing how it could be implemented
    print('Allowed area updated: lat=$latitude, lon=$longitude, radius=$radius meters');
  }
}
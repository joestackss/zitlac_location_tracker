import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';

part 'location.g.dart';

@HiveType(typeId: 0)
class GeofenceLocation {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final double radius; // in meters

  const GeofenceLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 50.0, // Default radius of 50 meters
  });

  // Helper method to check if a point is within this location's geofence
  bool isPointInside(double lat, double lng) {
    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      latitude,
      longitude,
    );
    return distance <= radius;
  }

  // Predefined locations
  static const home = GeofenceLocation(
    name: "Home",
    latitude: 37.7749,
    longitude: -122.4194,
    radius: 50.0,
  );

  static const office = GeofenceLocation(
    name: "Office",
    latitude: 37.7858,
    longitude: -122.4364,
    radius: 50.0,
  );

  // Get all predefined locations
  static List<GeofenceLocation> getPredefinedLocations() {
    return [home, office];
  }
} 
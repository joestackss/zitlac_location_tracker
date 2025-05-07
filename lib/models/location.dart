import 'package:hive/hive.dart';

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
    return true; // We'll implement this later using geolocator
  }
} 
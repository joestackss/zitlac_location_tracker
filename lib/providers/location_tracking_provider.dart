import 'package:flutter/foundation.dart';
import 'package:background_location/background_location.dart' as bg_location;
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import '../models/location.dart';
import '../models/daily_summary.dart';

class LocationTrackingProvider with ChangeNotifier {
  bool _isTracking = false;
  DateTime? _lastUpdateTime;
  DailySummary? _currentDailySummary;
  final List<GeofenceLocation> _predefinedLocations = [
    const GeofenceLocation(
      name: "Home",
      latitude: 37.7749,
      longitude: -122.4194,
      radius: 50.0, // 50 meter radius as specified in the brief
    ),
    const GeofenceLocation(
      name: "Office",
      latitude: 37.7858,
      longitude: -122.4364,
      radius: 50.0, // 50 meter radius as specified in the brief
    ),
  ];

  bool get isTracking => _isTracking;
  DailySummary? get currentDailySummary => _currentDailySummary;

  Future<void> startTracking() async {
    if (_isTracking) return;

    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }

      // Initialize daily summary for today if not exists
      _initializeDailySummary();

      // Start background location service
      await bg_location.BackgroundLocation.setAndroidNotification(
        title: "Location Tracking",
        message: "Tracking your location",
        icon: "@mipmap/ic_launcher",
      );
      
      await bg_location.BackgroundLocation.startLocationService(distanceFilter: 10);
      bg_location.BackgroundLocation.getLocationUpdates((location) {
        _handleLocationUpdate(location.latitude!, location.longitude!);
      });

      _isTracking = true;
      _lastUpdateTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('Error starting location tracking: $e');
      rethrow;
    }
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    try {
      await bg_location.BackgroundLocation.stopLocationService();
      _isTracking = false;
      await _saveDailySummary();
      notifyListeners();
    } catch (e) {
      print('Error stopping location tracking: $e');
      rethrow;
    }
  }

  void _initializeDailySummary() {
    final today = DateTime.now();
    _currentDailySummary = DailySummary(
      date: DateTime(today.year, today.month, today.day),
    );
  }

  void _handleLocationUpdate(double latitude, double longitude) {
    if (!_isTracking || _lastUpdateTime == null) return;

    final now = DateTime.now();
    final timeDelta = now.difference(_lastUpdateTime!);
    bool isInsideAnyLocation = false;

    // Check each predefined location
    for (var location in _predefinedLocations) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        location.latitude,
        location.longitude,
      );

      if (distance <= location.radius) {
        isInsideAnyLocation = true;
        _currentDailySummary?.addTimeInLocation(location.name, timeDelta);
      }
    }

    // If not in any location, add to traveling time
    if (!isInsideAnyLocation) {
      _currentDailySummary?.addTravelingTime(timeDelta);
    }

    _lastUpdateTime = now;
    notifyListeners();
  }

  Future<void> _saveDailySummary() async {
    if (_currentDailySummary == null) return;

    try {
      final box = await Hive.openBox<DailySummary>('daily_summaries');
      await box.put(_currentDailySummary!.getFormattedDate(), _currentDailySummary!);
    } catch (e) {
      print('Error saving daily summary: $e');
    }
  }
} 
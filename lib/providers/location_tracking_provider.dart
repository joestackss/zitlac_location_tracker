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
  final List<GeofenceLocation> _predefinedLocations = GeofenceLocation.getPredefinedLocations();

  bool get isTracking => _isTracking;
  DailySummary? get currentDailySummary => _currentDailySummary;
  List<GeofenceLocation> get predefinedLocations => _predefinedLocations;

  Future<void> startTracking() async {
    if (_isTracking) return;

    try {
     
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }


      _initializeDailySummary();

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
      sessionStartTime: today,
    );
  }

  void _handleLocationUpdate(double latitude, double longitude) {
    if (!_isTracking || _lastUpdateTime == null) return;

    final now = DateTime.now();
    final timeDelta = now.difference(_lastUpdateTime!);
    bool isInsideAnyLocation = false;

   
    for (var location in _predefinedLocations) {
      if (location.isPointInside(latitude, longitude)) {
        isInsideAnyLocation = true;
        _currentDailySummary?.addTimeInLocation(location.name, timeDelta);
        print('Inside location: ${location.name}'); 
      }
    }


    if (!isInsideAnyLocation) {
      _currentDailySummary?.addTravelingTime(timeDelta);
      print('Traveling'); 
    }

    _lastUpdateTime = now;
    notifyListeners();
  }

  Future<void> _saveDailySummary() async {
    if (_currentDailySummary == null) return;

    try {
      final box = await Hive.openBox<DailySummary>('daily_summaries');
      await box.put(_currentDailySummary!.getStorageKey(), _currentDailySummary!);
    } catch (e) {
      print('Error saving daily summary: $e');
      rethrow;
    }
  }

  Future<void> updateCurrentLocation(double latitude, double longitude) {
    _predefinedLocations[0] = GeofenceLocation(
      name: "Current Location",
      latitude: latitude,
      longitude: longitude,
      radius: 50.0,
    );
    notifyListeners();
    return Future.value();
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_tracking_provider.dart';
import 'summary_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services'),
      ));
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permissions are permanently denied, we cannot request permissions.'),
      ));
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    try {
      final hasPermission = await _handleLocationPermission(context);
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Current Location:\nLat: ${position.latitude}\nLng: ${position.longitude}',
          ),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Copy',
            onPressed: () {
              // Add clipboard functionality if needed
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_searching),
            onPressed: () => _getCurrentLocation(context),
          ),
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SummaryScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Consumer<LocationTrackingProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.isTracking ? 'Currently Tracking' : 'Not Tracking',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (provider.isTracking) {
                        await provider.stopTracking();
                      } else {
                        final hasPermission = await _handleLocationPermission(context);
                        if (hasPermission) {
                          await provider.startTracking();
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    provider.isTracking ? 'Clock Out' : 'Clock In',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 
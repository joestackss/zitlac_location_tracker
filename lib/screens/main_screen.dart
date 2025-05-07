import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
        content: Text('Location permissions are permanently denied.'),
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Location Tracker',
          style: TextStyle(fontFamily: 'Barlow'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.chart_bar_alt_fill),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const SummaryScreen()),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Consumer<LocationTrackingProvider>(
          builder: (context, provider, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isTracking
                          ? CupertinoColors.activeGreen.withOpacity(0.1)
                          : CupertinoColors.systemGrey5,
                    ),
                    child: Center(
                      child: Text(
                        provider.isTracking ? 'Tracking Active' : 'Not Tracking',
                        style: TextStyle(
                          fontFamily: 'Barlow',
                          fontSize: 18,
                          color: provider.isTracking
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CupertinoButton.filled(
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
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: Text(e.toString()),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text(
                      provider.isTracking ? 'Clock Out' : 'Clock In',
                      style: const TextStyle(
                        fontFamily: 'Barlow',
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 
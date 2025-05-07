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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text('Please enable location services in your device settings.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Location Permission'),
              content: const Text('Location permissions are required for tracking.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Location Permission'),
            content: const Text('Location permissions are permanently denied. Please enable them in settings.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return true;
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.isTracking ? 'Tracking Active' : 'Not Tracking',
                            style: TextStyle(
                              fontFamily: 'Barlow',
                              fontSize: 18,
                              color: provider.isTracking
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                          if (provider.isTracking) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Test near:',
                              style: TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            Text(
                              provider.predefinedLocations[1].name,
                              style: TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ],
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
                            final position = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high
                            );
                            await provider.updateCurrentLocation(
                              position.latitude,
                              position.longitude,
                            );
                            await provider.startTracking();
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
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
                  const SizedBox(height: 16),
                  Text(
                    'For testing: Move slightly from your current location',
                    style: TextStyle(
                      fontFamily: 'Barlow',
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    textAlign: TextAlign.center,
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
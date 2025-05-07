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
            content: const Text('Please enable location services to use this app.'),
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
              title: const Text('Location Permission Denied'),
              content: const Text('Location permissions are required to use this app.'),
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
            title: const Text('Location Permission Denied'),
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
              CupertinoPageRoute(
                builder: (context) => const SummaryScreen(),
              ),
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
                  const Spacer(),
                  Text(
                    provider.isTracking ? 'Currently Tracking' : 'Not Tracking',
                    style: const TextStyle(
                      fontFamily: 'Barlow',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 
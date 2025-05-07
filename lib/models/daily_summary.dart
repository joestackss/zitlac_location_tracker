import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'daily_summary.g.dart';

@HiveType(typeId: 1)
class DailySummary {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final Map<String, Duration> timeSpentByLocation;

  @HiveField(2)
  Duration travelingTime;

  @HiveField(3)
  final DateTime sessionStartTime;

  DailySummary({
    required this.date,
    Map<String, Duration>? timeSpentByLocation,
    Duration? travelingTime,
    DateTime? sessionStartTime,
  })  : timeSpentByLocation = timeSpentByLocation ?? {},
        travelingTime = travelingTime ?? Duration.zero,
        sessionStartTime = sessionStartTime ?? DateTime.now();

  void addTimeInLocation(String locationName, Duration duration) {
    timeSpentByLocation[locationName] = (timeSpentByLocation[locationName] ?? Duration.zero) + duration;
  }

  void addTravelingTime(Duration duration) {
    travelingTime += duration;
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String getFormattedTimeForLocation(String locationName) {
    return formatDuration(timeSpentByLocation[locationName] ?? Duration.zero);
  }


  String getFormattedTravelingTime() {
    return formatDuration(travelingTime);
  }

  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String getFormattedSessionStartTime() {
    return DateFormat('HH:mm:ss').format(sessionStartTime);
  }

  String getStorageKey() {
    return '${getFormattedDate()}_${DateFormat('HHmmss').format(sessionStartTime)}';
  }
} 
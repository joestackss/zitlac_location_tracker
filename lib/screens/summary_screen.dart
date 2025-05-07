import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/location_tracking_provider.dart';
import '../models/daily_summary.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  // Group summaries by date
  Map<String, List<DailySummary>> _groupSummariesByDate(List<DailySummary> summaries) {
    final grouped = <String, List<DailySummary>>{};
    for (var summary in summaries) {
      final date = summary.getFormattedDate();
      grouped.putIfAbsent(date, () => []).add(summary);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Daily Summary',
          style: TextStyle(fontFamily: 'Barlow'),
        ),
      ),
      child: SafeArea(
        child: Consumer<LocationTrackingProvider>(
          builder: (context, provider, child) {
            return ValueListenableBuilder<Box<DailySummary>>(
              valueListenable: Hive.box<DailySummary>('daily_summaries').listenable(),
              builder: (context, box, child) {
                final currentSummary = provider.currentDailySummary;
                final savedSummaries = box.values.toList();
                
                // Group all summaries by date
                final groupedSummaries = _groupSummariesByDate(
                  currentSummary != null ? [currentSummary, ...savedSummaries] : savedSummaries
                );

                // Sort dates in descending order
                final dates = groupedSummaries.keys.toList()..sort((a, b) => b.compareTo(a));

                if (dates.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tracking data yet',
                      style: TextStyle(
                        fontFamily: 'Barlow',
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, dateIndex) {
                    final date = dates[dateIndex];
                    final summariesForDate = groupedSummaries[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontFamily: 'Barlow',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...summariesForDate.map((summary) => Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session: ${summary.getFormattedSessionStartTime()}',
                                  style: const TextStyle(
                                    fontFamily: 'Barlow',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...summary.timeSpentByLocation.entries.map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontFamily: 'Barlow',
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          summary.formatDuration(entry.value),
                                          style: const TextStyle(
                                            fontFamily: 'Barlow',
                                            fontSize: 16,
                                            color: CupertinoColors.activeBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    height: 0.5,
                                    color: CupertinoColors.systemGrey4,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Traveling',
                                      style: TextStyle(
                                        fontFamily: 'Barlow',
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      summary.getFormattedTravelingTime(),
                                      style: const TextStyle(
                                        fontFamily: 'Barlow',
                                        fontSize: 16,
                                        color: CupertinoColors.activeBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
} 
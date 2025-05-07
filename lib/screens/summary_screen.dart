import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/location_tracking_provider.dart';
import '../models/daily_summary.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

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
                final savedSummaries = box.values.toList()
                  ..sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  itemCount: savedSummaries.length + (currentSummary != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    final summary = index == 0 && currentSummary != null
                        ? currentSummary
                        : savedSummaries[index - (currentSummary != null ? 1 : 0)];

                    return Container(
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
                              summary.getFormattedDate(),
                              style: const TextStyle(
                                fontFamily: 'Barlow',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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
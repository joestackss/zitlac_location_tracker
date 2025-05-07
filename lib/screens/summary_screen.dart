import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_tracking_provider.dart';
import '../models/daily_summary.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
      ),
      body: Consumer<LocationTrackingProvider>(
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

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.getFormattedDate(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          ...summary.timeSpentByLocation.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(summary.formatDuration(entry.value)),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Traveling'),
                              Text(summary.getFormattedTravelingTime()),
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
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../services/mood_service.dart';
import '../../../core/utils/storage_service.dart';

class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  List<int> _bucketsFrom(List<Map<String, dynamic>> history, int days) {
    final now = DateTime.now();
    final buckets = List<int>.filled(days, 0);
    for (final m in history) {
      final s = m['date'] as String?;
      if (s == null) continue;
      DateTime? dt;
      try { dt = DateTime.parse(s); } catch (_) { dt = null; }
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = now.difference(day).inDays;
      if (diff >= 0 && diff < days) {
        buckets[days - 1 - diff] += 1;
      }
    }
    return buckets;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(moodHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mood History')),
      body: AnimatedBackground(
        child: asyncHistory.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => FutureBuilder<List<Map<String, dynamic>>>(
            future: StorageService.getMoodHistory(),
            builder: (context, snap) {
              final list = snap.data ?? [];
              return _Content(history: list);
            },
          ),
          data: (list) => _Content(history: list),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _Content({required this.history});

  @override
  Widget build(BuildContext context) {
    final buckets14 = MoodHistoryScreen()._bucketsFrom(history, 14);
    final maxVal = buckets14.isEmpty ? 0 : (buckets14.reduce((a, b) => a > b ? a : b));
    final spots = [
      for (int i = 0; i < buckets14.length; i++) FlSpot(i.toDouble(), buckets14[i].toDouble())
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Mood Trend (last 14 days)',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              minY: 0,
              maxY: (maxVal + 1).toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: AppColors.primary,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        Text(
          'Recent Entries',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        ...history.take(20).map((e) {
          final mood = e['mood'] as String? ?? '';
          final date = e['date'] as String? ?? '';
          return Card(
            child: ListTile(
              leading: const Icon(Icons.mood_outlined, color: AppColors.primary),
              title: Text(mood),
              subtitle: Text(date),
            ),
          ).animate().fadeIn(duration: 200.ms);
        }),
      ],
    );
  }
}


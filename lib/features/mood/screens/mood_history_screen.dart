import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../services/mood_service.dart';
import '../../../core/utils/storage_service.dart';

class MoodHistoryScreen extends ConsumerStatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  ConsumerState<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends ConsumerState<MoodHistoryScreen> {
  final Set<String> _selectedTags = {};
  int _minIntensity = 1;
  bool _showIntensity = false;

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

  List<double> _avgIntensityFrom(List<Map<String, dynamic>> history, int days) {
    final now = DateTime.now();
    final sums = List<double>.filled(days, 0);
    final counts = List<int>.filled(days, 0);
    for (final m in history) {
      final s = m['date'] as String?;
      if (s == null) continue;
      DateTime? dt;
      try { dt = DateTime.parse(s); } catch (_) { dt = null; }
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = now.difference(day).inDays;
      if (diff >= 0 && diff < days) {
        final val = (m['intensity'] as int?)?.toDouble() ?? 0.0;
        sums[days - 1 - diff] += val;
        counts[days - 1 - diff] += 1;
      }
    }
    return List<double>.generate(days, (i) => counts[i] == 0 ? 0 : sums[i] / counts[i]);
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> history) {
    return history.where((e) {
      final intensity = e['intensity'] as int?;
      final tags = (e['tags'] as List?)?.map((x) => x.toString()).toList() ?? const [];
      final passIntensity = intensity == null ? true : intensity >= _minIntensity;
      final passTags = _selectedTags.isEmpty ? true : tags.any((t) => _selectedTags.contains(t));
      return passIntensity && passTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              return _content(context, list);
            },
          ),
          data: (list) => _content(context, list),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, List<Map<String, dynamic>> history) {
    final allTags = <String>{};
    for (final e in history) {
      final tags = (e['tags'] as List?)?.map((x) => x.toString()).toList() ?? const [];
      allTags.addAll(tags);
    }
    final filtered = _applyFilters(history);
    final buckets14 = _bucketsFrom(filtered, 14);
    final maxVal = buckets14.isEmpty ? 0 : (buckets14.reduce((a, b) => a > b ? a : b));
    final spots = [for (int i = 0; i < buckets14.length; i++) FlSpot(i.toDouble(), buckets14[i].toDouble())];

    final avgIntensity = _avgIntensityFrom(filtered, 14);
    final maxInt = 5.0;
    final intSpots = [for (int i = 0; i < avgIntensity.length; i++) FlSpot(i.toDouble(), avgIntensity[i])];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            ChoiceChip(
              label: const Text('Counts'),
              selected: !_showIntensity,
              onSelected: (_) => setState(() => _showIntensity = false),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Avg Intensity'),
              selected: _showIntensity,
              onSelected: (_) => setState(() => _showIntensity = true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in allTags)
              FilterChip(
                label: Text(tag),
                selected: _selectedTags.contains(tag),
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Min intensity: $_minIntensity'),
            Expanded(
              child: Slider(
                value: _minIntensity.toDouble(),
                onChanged: (v) => setState(() => _minIntensity = v.round()),
                min: 1,
                max: 5,
                divisions: 4,
              ),
            ),
          ],
        ),
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
              maxY: _showIntensity ? maxInt : (maxVal + 1).toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: _showIntensity ? intSpots : spots,
                  isCurved: true,
                  barWidth: 3,
                  color: _showIntensity ? AppColors.secondary : AppColors.primary,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        Text('Recent Entries', style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        ...filtered.take(20).map((e) {
          final mood = e['mood'] as String? ?? '';
          final date = e['date'] as String? ?? '';
          final intensity = (e['intensity'] as int?)?.toString() ?? '';
          final tags = (e['tags'] as List?)?.map((x) => x.toString()).join(', ') ?? '';
          return Card(
            child: ListTile(
              leading: const Icon(Icons.mood_outlined, color: AppColors.primary),
              title: Text(mood),
              subtitle: Text([date, if (intensity.isNotEmpty) 'Intensity $intensity', if (tags.isNotEmpty) tags].join(' • ')),
            ),
          ).animate().fadeIn(duration: 200.ms);
        }),
      ],
    );
  }
}


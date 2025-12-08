import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../services/mood_service.dart';
import '../../../services/user_service.dart';
import '../../../core/utils/storage_service.dart';
import '../../../data/models/mood_entry.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

final _selectedMoodProvider = StateProvider<String?>((ref) => null);

class MoodSelector extends ConsumerStatefulWidget {
  const MoodSelector({super.key});

  @override
  ConsumerState<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends ConsumerState<MoodSelector> {
  final List<MoodOption> _moods = const [
    MoodOption(
      iconPath: 'assets/icons/lovers.png',
      label: AppStrings.moodHappy,
      color: AppColors.moodHappy,
    ),
    MoodOption(
      iconPath: 'assets/icons/laugh-emoji.png',
      label: AppStrings.moodOkay,
      color: AppColors.moodNeutral,
    ),
    MoodOption(
      iconPath: 'assets/icons/cry-emoji.png',
      label: AppStrings.moodSad,
      color: AppColors.moodSad,
    ),
    MoodOption(
      iconPath: 'assets/icons/angry.png',
      label: AppStrings.moodAnxious,
      color: AppColors.moodAnxiety,
    ),
    MoodOption(
      iconPath: 'assets/icons/licking.png',
      label: AppStrings.moodCalm,
      color: AppColors.softAqua,
    ),
  ];

  Future<void> _selectMood(String mood) async {
    ref.read(_selectedMoodProvider.notifier).state = mood;
    await _openDetailsSheet(mood);
  }

  Future<void> _openDetailsSheet(String mood) async {
    int intensity = 3;
    final TextEditingController noteController = TextEditingController();
    final Set<String> selectedTags = {};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mood_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Record mood', style: Theme.of(ctx).textTheme.titleMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Intensity: $intensity/5'),
                    Slider(
                      value: intensity.toDouble(),
                      onChanged: (v) {
                        setModalState(() { intensity = v.round(); });
                      },
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$intensity',
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(hintText: 'Add a note (optional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in const ['sleep','stress','work','study','social','health','relationships'])
                          FilterChip(
                            label: Text(tag),
                            selected: selectedTags.contains(tag),
                            onSelected: (sel) {
                              setModalState(() {
                                if (sel) { selectedTags.add(tag); } else { selectedTags.remove(tag); }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveMoodDetails(
                            mood,
                            intensity,
                            noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                            selectedTags.toList(),
                          );
                          if (mounted) Navigator.of(ctx).pop();
                          if (mounted) _showRecommendations(mood, intensity);
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveMoodDetails(String mood, int intensity, String? note, List<String> tags) async {
    try {
      final moodService = ref.read(moodServiceProvider);
      await moodService.saveMood(mood, intensity: intensity, note: note, tags: tags);
      await ref.read(userServiceProvider).updateLastMood(mood);
    } catch (e) {
      final entry = MoodEntry(
        id: const Uuid().v4(),
        mood: mood,
        date: DateTime.now(),
        note: note,
        intensity: intensity,
        tags: tags,
      );
      await StorageService.addMoodEntry(entry.toJson());
    }

    if (mounted) {
      try {
        final history = await ref.read(moodServiceProvider).getMoodHistory();
        final count = history.length;
        final badges = await StorageService.getBadges();
        if (count >= 5 && !badges.contains('mood_5')) {
          await StorageService.addBadge('mood_5');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Badge earned: Mood Explorer'), backgroundColor: AppColors.accent),
          );
        }
        if (count >= 20 && !badges.contains('mood_20')) {
          await StorageService.addBadge('mood_20');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Badge earned: Mood Master'), backgroundColor: AppColors.secondary),
          );
        }
      } catch (_) {
        final history = await StorageService.getMoodHistory();
        final count = history.length;
        final badges = await StorageService.getBadges();
        if (count >= 5 && !badges.contains('mood_5')) {
          await StorageService.addBadge('mood_5');
        }
        if (count >= 20 && !badges.contains('mood_20')) {
          await StorageService.addBadge('mood_20');
        }
      }
    }
  }

  void _showRecommendations(String mood, int intensity) {
    String msg;
    String actionLabel;
    String route;
    if (mood == AppStrings.moodAnxious || intensity >= 4) {
      msg = 'Try a short breathing exercise';
      actionLabel = 'Start';
      route = '/breathing';
    } else if (mood == AppStrings.moodSad) {
      msg = 'Write a quick journal entry';
      actionLabel = 'Open';
      route = '/journal';
    } else {
      msg = 'Explore a worksheet for reflection';
      actionLabel = 'Browse';
      route = '/worksheets';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(label: actionLabel, onPressed: () => context.push(route)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMood = ref.watch(_selectedMoodProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySkyBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _moods.map((mood) {
          final isSelected = selectedMood == mood.label;
          return GestureDetector(
            onTap: () => _selectMood(mood.label),
            child: Column(
              children: [
                Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: mood.color.withOpacity(isSelected ? 1.0 : 0.2),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primarySkyBlue,
                                width: 3,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Image.asset(
                          mood.iconPath,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 200.ms,
                    ),
                const SizedBox(height: 8),
                Text(
                  mood.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.primarySkyBlue
                        : AppColors.lightGray300,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MoodOption {
  final String iconPath;
  final String label;
  final Color color;

  const MoodOption({
    required this.iconPath,
    required this.label,
    required this.color,
  });
}

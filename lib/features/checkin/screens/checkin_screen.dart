import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' show ImageFilter;
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/widgets/counseling_floating_button.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _index = 0;
  final List<_Question> _questions = [
    _Question(
      title: 'How are you feeling today?',
      icon: Icons.sentiment_satisfied_alt,
      options: const [
        _Option(label: 'Happy', icon: Icons.sentiment_satisfied, points: 0),
        _Option(label: 'Okay', icon: Icons.sentiment_neutral, points: 1),
        _Option(label: 'Sad', icon: Icons.sentiment_dissatisfied, points: 2),
        _Option(label: 'Anxious', icon: Icons.mood_bad, points: 3),
      ],
    ),
    _Question(
      title: 'How stressed do you feel?',
      icon: Icons.monitor_heart,
      options: const [
        _Option(label: 'Very', icon: Icons.sentiment_very_dissatisfied, points: 3),
        _Option(label: 'Somewhat', icon: Icons.psychology_alt, points: 2),
        _Option(label: 'Slightly', icon: Icons.self_improvement, points: 1),
        _Option(label: 'Not at all', icon: Icons.sentiment_very_satisfied, points: 0),
      ],
    ),
    _Question(
      title: 'Did you sleep well last night?',
      icon: Icons.nightlight_round,
      options: const [
        _Option(label: 'Poor', icon: Icons.bedtime, points: 3),
        _Option(label: 'Average', icon: Icons.cloud, points: 2),
        _Option(label: 'Good', icon: Icons.nightlight, points: 1),
        _Option(label: 'Excellent', icon: Icons.wb_sunny, points: 0),
      ],
    ),
    _Question(
      title: 'Are you motivated to work/study today?',
      icon: Icons.rocket_launch,
      options: const [
        _Option(label: 'Not at all', icon: Icons.do_not_disturb, points: 3),
        _Option(label: 'Slightly', icon: Icons.trending_flat, points: 2),
        _Option(label: 'Moderately', icon: Icons.trending_up, points: 1),
        _Option(label: 'Very', icon: Icons.local_fire_department, points: 0),
      ],
    ),
    _Question(
      title: 'How often did you exercise this week?',
      icon: Icons.fitness_center,
      options: const [
        _Option(label: 'Never', icon: Icons.chair_alt, points: 3),
        _Option(label: '1–2 days', icon: Icons.directions_walk, points: 2),
        _Option(label: '3–4 days', icon: Icons.run_circle, points: 1),
        _Option(label: '5+ days', icon: Icons.fitness_center, points: 0),
      ],
    ),
    _Question(
      title: 'How is your focus today?',
      icon: Icons.center_focus_strong,
      options: const [
        _Option(label: 'Poor', icon: Icons.blur_on, points: 3),
        _Option(label: 'Average', icon: Icons.remove_red_eye, points: 2),
        _Option(label: 'Good', icon: Icons.visibility, points: 1),
        _Option(label: 'Excellent', icon: Icons.auto_awesome, points: 0),
      ],
    ),
    _Question(
      title: 'How social do you feel?',
      icon: Icons.groups_2,
      options: const [
        _Option(label: 'Isolated', icon: Icons.no_accounts, points: 3),
        _Option(label: 'Low', icon: Icons.person_outline, points: 2),
        _Option(label: 'Moderate', icon: Icons.group, points: 1),
        _Option(label: 'High', icon: Icons.groups, points: 0),
      ],
    ),
    _Question(
      title: 'How is your energy level?',
      icon: Icons.bolt,
      options: const [
        _Option(label: 'Very low', icon: Icons.battery_alert, points: 3),
        _Option(label: 'Low', icon: Icons.battery_2_bar, points: 2),
        _Option(label: 'Moderate', icon: Icons.battery_4_bar, points: 1),
        _Option(label: 'High', icon: Icons.battery_full, points: 0),
      ],
    ),
  ];

  final List<String> _responses = [];

  Future<void> _saveResult() async {
    int total = 0;
    for (int i = 0; i < _questions.length; i++) {
      final resp = _responses[i];
      final opt = _questions[i].options.firstWhere(
        (o) => o.label == resp,
        orElse: () => _questions[i].options.first,
      );
      total += opt.points;
    }
    final max = _questions.length * 3;
    String category;
    if (total <= (max * 0.33).round()) {
      category = 'low';
    } else if (total <= (max * 0.66).round()) {
      category = 'moderate';
    } else {
      category = 'high';
    }

    final payload = {
      'timestamp': DateTime.now().toIso8601String(),
      'total': total,
      'max': max,
      'category': category,
      'responses': _responses,
    };

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final col = FirebaseFirestore.instance.collection('checkins').doc(uid).collection('entries');
        await col.add(payload);
      } else {
        throw Exception('no user');
      }
    } catch (_) {
      await _saveCheckinLocal(payload);
    }
  }

  Future<void> _saveCheckinLocal(Map<String, dynamic> entry) async {
    await StorageService.saveCheckinEntry(entry);
  }

  void _selectOption(int optionIndex) {
    final selected = _questions[_index].options[optionIndex].label;
    _responses.add(selected);
    if (_index < _questions.length - 1) {
      setState(() {
        _index += 1;
      });
    } else {
      setState(() {});
      _saveResult();
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _responses.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;
    final isDone = _responses.length == total;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Daily Check-in'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: AnimatedBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with progress info
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDone ? 'Check-in Complete' : 'Daily Check-in',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isDone 
                              ? 'Here\'s your emotional wellness summary' 
                              : 'Question ${_index + 1} of $total',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Progress indicators
                    Column(
                      children: [
                        // Progress bar
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final progress = isDone ? 1.0 : (_index + 1) / total;
                            final width = constraints.maxWidth * progress;
                            return Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: 400.ms,
                                    curve: Curves.easeOutCubic,
                                    width: width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: AppColors.primaryGradient,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        // Dots indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(total, (i) {
                            final active = isDone ? i == total - 1 : i == _index;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: active
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ).animate(target: active ? 1 : 0).scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: 200.ms,
                            );
                          }),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // Content area
                    Expanded(
                      child: isDone
                          ? _Summary(responses: _responses, questions: _questions)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.1, end: 0)
                          : _QuestionCard(
                              question: _questions[_index],
                              onSelect: _selectOption,
                            )
                              .animate(key: ValueKey(_index))
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.05, end: 0),
                    ),

                    // Restart button (only when done)
                    if (isDone)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _restart,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, size: 20),
                                SizedBox(width: 8),
                                Text('Start New Check-in', style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const CounselingFloatingButton(),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final _Question question;
  final void Function(int) onSelect;
  const _QuestionCard({required this.question, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.glassShadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      question.icon,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      question.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Options grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: question.options.length,
          itemBuilder: (context, index) {
            final option = question.options[index];
            return _OptionCard(
              label: option.label,
              icon: option.icon,
              onTap: () => onSelect(index),
            );
          },
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OptionCard({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.glassShadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Changed to black
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(
        begin: const Offset(0.98, 0.98),
        end: const Offset(1, 1),
        duration: 200.ms,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final List<String> responses;
  final List<_Question> questions;
  const _Summary({required this.responses, required this.questions});

  @override
  Widget build(BuildContext context) {
    int total = 0;
    for (int i = 0; i < questions.length; i++) {
      final resp = responses[i];
      final opt = questions[i].options.firstWhere(
        (o) => o.label == resp,
        orElse: () => questions[i].options.first,
      );
      total += opt.points;
    }

    final max = questions.length * 3;
    String category;
    String description;
    IconData categoryIcon;
    Color categoryColor;
    
    // Scale thresholds for any question count
    if (total <= (max * 0.33).round()) {
      category = 'Calm & Balanced';
      description = 'You\'re doing great! Keep up the good work.';
      categoryIcon = Icons.emoji_emotions;
      categoryColor = AppColors.primaryMintGreen;
    } else if (total <= (max * 0.66).round()) {
      category = 'Moderate Stress';
      description = 'Take some time for self-care today.';
      categoryIcon = Icons.psychology;
      categoryColor = AppColors.lavender;
    } else {
      category = 'Needs Support';
      description = 'Consider reaching out for support or taking a break.';
      categoryIcon = Icons.health_and_safety;
      categoryColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: categoryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(categoryIcon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black, // Changed to black
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87, // Changed to black
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: $total / $max',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54, // Changed to black
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 24),

        // Response list header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Your Responses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black, // Changed to black
            ),
          ),
        ),

        // Responses list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: questions.length,
            itemBuilder: (context, i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glassShadow.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        questions[i].icon,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questions[i].title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black, // Changed to black
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            responses[i],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 50).ms);
            },
          ),
        ),
      ],
    );
  }
}

class _Question {
  final String title;
  final IconData icon;
  final List<_Option> options;
  const _Question({required this.title, required this.icon, required this.options});
}

class _Option {
  final String label;
  final IconData icon;
  final int points;
  const _Option({required this.label, required this.icon, required this.points});
}
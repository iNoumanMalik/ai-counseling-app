import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';

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

  void _selectOption(int optionIndex) {
    final selected = _questions[_index].options[optionIndex].label;
    _responses.add(selected);
    if (_index < _questions.length - 1) {
      setState(() {
        _index += 1;
      });
    } else {
      setState(() {});
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
    return Scaffold(
      appBar: AppBar(title: const Text('MCQ Check-in')),
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isDone ? 'Summary' : 'Question ${_index + 1} of $total',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: isDone ? 1 : (_index + 1) / total,
                    minHeight: 6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: isDone
                      ? _Summary(responses: _responses, questions: _questions)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0)
                      : _QuestionCard(
                          question: _questions[_index],
                          onSelect: _selectOption,
                        )
                          .animate(key: ValueKey(_index))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.2, end: 0),
                ),

                if (isDone)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restart'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final _Question question;
  final void Function(int) onSelect;
  const _QuestionCard({required this.question, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(question.icon, color: AppColors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < question.options.length; i++)
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(question.options[i].icon, size: 18, color: AppColors.dark900),
                        const SizedBox(width: 6),
                        Text(question.options[i].label),
                      ],
                    ),
                    selected: false,
                    onSelected: (_) => onSelect(i),
                    backgroundColor: AppColors.lightGray200,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.dark900),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
              ],
            ),
          ],
        ),
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
    IconData categoryIcon;
    Color categoryColor;
    // Scale thresholds for any question count
    if (total <= (max * 0.33).round()) {
      category = 'Calm / Low stress';
      categoryIcon = Icons.sentiment_very_satisfied;
      categoryColor = AppColors.primaryMintGreen;
    } else if (total <= (max * 0.66).round()) {
      category = 'Moderate stress';
      categoryIcon = Icons.sentiment_neutral;
      categoryColor = AppColors.lavender;
    } else {
      category = 'High stress / Needs support';
      categoryIcon = Icons.sentiment_very_dissatisfied;
      categoryColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(categoryIcon, color: AppColors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Score: $total / $max',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, i) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(questions[i].icon, color: AppColors.primary),
                  title: Text(questions[i].title),
                  subtitle: Text('Your choice: ${responses[i]}'),
                ),
              ).animate().fadeIn(duration: 200.ms);
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

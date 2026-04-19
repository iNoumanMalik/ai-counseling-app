import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';

class WorksheetsScreen extends StatelessWidget {
  const WorksheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worksheets = const [
      Worksheet(
        id: 'grounding',
        title: '5-4-3-2-1 Grounding Exercise',
        description: 'A technique to help manage anxiety and panic attacks',
        icon: Icons.nature_outlined,
        color: AppColors.secondary,
      ),
      Worksheet(
        id: 'gratitude',
        title: 'Gratitude Journal',
        description: 'Reflect on gratitude with simple prompts',
        icon: Icons.favorite_outline,
        color: AppColors.accent,
      ),
      Worksheet(
        id: 'anxiety',
        title: 'Anxiety/Worry Worksheet',
        description: 'Structure worries and plan actions',
        icon: Icons.psychology_outlined,
        color: AppColors.primary,
      ),
      Worksheet(
        id: 'exercise',
        title: 'Exercise Log',
        description: 'Record a structured exercise session',
        icon: Icons.fitness_center_outlined,
        color: AppColors.softAqua,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CBT Worksheets'),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Self-Help Worksheets',
                style: Theme.of(context).textTheme.displaySmall,
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Tools to help you on your journey',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mediumGray,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 32),

              ...worksheets.map((worksheet) {
                final index = worksheets.indexOf(worksheet);
                return _WorksheetCard(
                  worksheet: worksheet,
                  onTap: () {
                    context.push('/worksheets/${worksheet.id}');
                  },
                )
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorksheetCard extends StatelessWidget {
  final Worksheet worksheet;
  final VoidCallback onTap;

  const _WorksheetCard({
    required this.worksheet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: worksheet.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  worksheet.icon,
                  color: worksheet.color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worksheet.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      worksheet.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.mediumGray,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}

class Worksheet {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const Worksheet({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}


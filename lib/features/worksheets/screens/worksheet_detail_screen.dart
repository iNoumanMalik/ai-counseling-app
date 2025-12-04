import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';

class WorksheetDetailScreen extends StatefulWidget {
  final String id;
  const WorksheetDetailScreen({super.key, required this.id});

  @override
  State<WorksheetDetailScreen> createState() => _WorksheetDetailScreenState();
}

class _WorksheetDetailScreenState extends State<WorksheetDetailScreen> {
  int _stepIndex = 0;

  void _nextStep() {
    setState(() {
      _stepIndex = (_stepIndex + 1) % 5;
    });
  }

  Future<void> _openCbtPdf() async {
    final uri = Uri.parse('https://www.therapistaid.com/worksheets/cbt-thought-record.pdf');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == 'cbt' ? 'CBT Thought Record' : widget.id == 'grounding' ? '5-4-3-2-1 Grounding' : 'Worksheet'),
      ),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: widget.id == 'cbt'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cognitive Behavioral Therapy Thought Record',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),
                    Text(
                      'Track situations, thoughts, feelings, and helpful responses.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: const [
                            TextField(decoration: InputDecoration(hintText: 'Situation')),
                            SizedBox(height: 12),
                            TextField(decoration: InputDecoration(hintText: 'Automatic thoughts')),
                            SizedBox(height: 12),
                            TextField(decoration: InputDecoration(hintText: 'Feelings (0–100%)')),
                            SizedBox(height: 12),
                            TextField(decoration: InputDecoration(hintText: 'Evidence for/against')),
                            SizedBox(height: 12),
                            TextField(decoration: InputDecoration(hintText: 'Balanced response')),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _openCbtPdf,
                        child: const Text('Open PDF'),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                  ],
                )
              : widget.id == 'grounding'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('5-4-3-2-1 Grounding', style: Theme.of(context).textTheme.titleLarge)
                            .animate()
                            .fadeIn(duration: 300.ms),
                        const SizedBox(height: 12),
                        Text('Tap next and notice your surroundings using senses.', style: Theme.of(context).textTheme.bodyMedium)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 300.ms),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _stepIndex == 0
                                      ? '5 things you can see'
                                      : _stepIndex == 1
                                          ? '4 things you can touch'
                                          : _stepIndex == 2
                                              ? '3 things you can hear'
                                              : _stepIndex == 3
                                                  ? '2 things you can smell'
                                                  : '1 thing you can taste',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            )
                                .animate(target: _stepIndex.toDouble())
                                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 500.ms)
                                .shimmer(duration: 1800.ms),
                        ),
                      ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            child: const Text('Next'),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text('Worksheet not available'),
                    ),
        ),
      ),
    );
  }
}

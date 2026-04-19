import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/worksheet_service.dart';

class WorksheetDetailScreen extends StatefulWidget {
  final String id;
  const WorksheetDetailScreen({super.key, required this.id});

  @override
  State<WorksheetDetailScreen> createState() => _WorksheetDetailScreenState();
}

class _WorksheetDetailScreenState extends State<WorksheetDetailScreen> {
  int _stepIndex = 0;
  final TextEditingController _g1 = TextEditingController();
  final TextEditingController _g2 = TextEditingController();
  final TextEditingController _g3 = TextEditingController();
  final TextEditingController _gWhy = TextEditingController();
  final TextEditingController _anxWhat = TextEditingController();
  final TextEditingController _anxWorst = TextEditingController();
  final TextEditingController _anxLikely = TextEditingController();
  final TextEditingController _anxControl = TextEditingController();
  final TextEditingController _anxActions = TextEditingController();
  double _anxLikelihood = 50;
  double _anxBefore = 50;
  double _anxAfter = 30;
  int _exAnimVersion = 0;
  final List<Map<String, dynamic>> _exerciseFlow = [
    {'label': 'Jump', 'icon': Icons.directions_run},
    {'label': 'Neck rolls', 'icon': Icons.rotate_right},
    {'label': 'Move your eyeballs', 'icon': Icons.remove_red_eye_outlined},
    {'label': 'Smile', 'icon': Icons.emoji_emotions_outlined},
    {'label': 'Stretch', 'icon': Icons.self_improvement_outlined},
    {'label': 'Deep breaths', 'icon': Icons.air},
    {'label': 'Shoulder shrugs', 'icon': Icons.accessibility_new},
    {'label': 'Toe touches', 'icon': Icons.accessibility},
  ];
  int _exerciseIndex = -1;
  bool _isExerciseRunning = false;
  int _countdown = 0;
  int _exRemainingSeconds = 5;
  Timer? _exerciseTimer;

  void _nextStep() {
    setState(() {
      _stepIndex = (_stepIndex + 1) % 5;
    });
  }

  @override
  void dispose() {
    _g1.dispose();
    _g2.dispose();
    _g3.dispose();
    _gWhy.dispose();
    _anxWhat.dispose();
    _anxWorst.dispose();
    _anxLikely.dispose();
    _anxControl.dispose();
    _anxActions.dispose();
    _exerciseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.id == 'gratitude'
              ? 'Gratitude Journal'
              : widget.id == 'anxiety'
                  ? 'Anxiety/Worry Worksheet'
                  : widget.id == 'exercise'
                      ? 'Exercise Log'
                      : widget.id == 'grounding'
                          ? '5-4-3-2-1 Grounding'
                          : 'Worksheet',
        ),
      ),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: widget.id == 'gratitude'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gratitude Journal', style: Theme.of(context).textTheme.titleLarge)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    const SizedBox(height: 8),
                    Text('Date: ${DateTime.now().toIso8601String().substring(0, 10)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mediumGray)),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(controller: _g1, decoration: const InputDecoration(hintText: "I'm grateful for #1")),
                            const SizedBox(height: 12),
                            TextField(controller: _g2, decoration: const InputDecoration(hintText: "I'm grateful for #2")),
                            const SizedBox(height: 12),
                            TextField(controller: _g3, decoration: const InputDecoration(hintText: "I'm grateful for #3")),
                            const SizedBox(height: 12),
                            TextField(controller: _gWhy, decoration: const InputDecoration(hintText: 'Why it matters (optional)')),
                            const SizedBox(height: 12),
                            // Row(
                            //   children: const [
                            //     Icon(Icons.photo_outlined),
                            //     SizedBox(width: 8),
                            //     Expanded(child: Text('Photo attachment (optional)')),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await WorksheetService(FirebaseFirestore.instance, FirebaseAuth.instance).saveEntry(
                              worksheetId: 'gratitude',
                              data: {
                                'g1': _g1.text,
                                'g2': _g2.text,
                                'g3': _g3.text,
                                'why': _gWhy.text,
                                'date': DateTime.now().toIso8601String(),
                              },
                            );
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gratitude saved')));
                          } catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save')));
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                )
              : widget.id == 'anxiety'
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anxiety/Worry Worksheet', style: Theme.of(context).textTheme.titleLarge)
                              .animate()
                              .fadeIn(duration: 300.ms),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  TextField(controller: _anxWhat, decoration: const InputDecoration(hintText: 'What am I worried about?')),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('Likelihood (0–100%)'),
                                      Expanded(
                                        child: Slider(
                                          value: _anxLikelihood,
                                          min: 0,
                                          max: 100,
                                          onChanged: (v) => setState(() => _anxLikelihood = v),
                                        ),
                                      ),
                                      Text('${_anxLikelihood.round()}%'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(controller: _anxWorst, decoration: const InputDecoration(hintText: "What's the worst that could happen?")),
                                  const SizedBox(height: 12),
                                  TextField(controller: _anxLikely, decoration: const InputDecoration(hintText: "What's more likely to happen?")),
                                  const SizedBox(height: 12),
                                  TextField(controller: _anxControl, decoration: const InputDecoration(hintText: 'What can I control?')),
                                  const SizedBox(height: 12),
                                  TextField(controller: _anxActions, decoration: const InputDecoration(hintText: 'Action steps')),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Text('Worry before'),
                                      Expanded(
                                        child: Slider(
                                          value: _anxBefore,
                                          min: 0,
                                          max: 100,
                                          onChanged: (v) => setState(() => _anxBefore = v),
                                        ),
                                      ),
                                      Text('${_anxBefore.round()}%'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Worry after'),
                                      Expanded(
                                        child: Slider(
                                          value: _anxAfter,
                                          min: 0,
                                          max: 100,
                                          onChanged: (v) => setState(() => _anxAfter = v),
                                        ),
                                      ),
                                      Text('${_anxAfter.round()}%'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await WorksheetService(FirebaseFirestore.instance, FirebaseAuth.instance).saveEntry(
                                    worksheetId: 'anxiety',
                                    data: {
                                      'what': _anxWhat.text,
                                      'likelihood': _anxLikelihood.round(),
                                      'worst': _anxWorst.text,
                                      'likely': _anxLikely.text,
                                      'control': _anxControl.text,
                                      'actions': _anxActions.text,
                                      'before': _anxBefore.round(),
                                      'after': _anxAfter.round(),
                                      'date': DateTime.now().toIso8601String(),
                                    },
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worksheet saved')));
                                } catch (_) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save')));
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    )
              : widget.id == 'exercise'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Exercise Flow', style: Theme.of(context).textTheme.titleLarge)
                            .animate()
                            .fadeIn(duration: 300.ms),
                        const SizedBox(height: 12),
                        if (!_isExerciseRunning)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isExerciseRunning = true;
                                  _countdown = 3;
                                  _exerciseIndex = -1;
                                });
                                _exerciseTimer?.cancel();
                                _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                                  if (_countdown > 1) {
                                    setState(() {
                                      _countdown -= 1;
                                    });
                                  } else {
                                    t.cancel();
                                    setState(() {
                                      _countdown = 0;
                                      _exerciseIndex = 0;
                                      _exRemainingSeconds = 5;
                                      _exAnimVersion += 1;
                                    });
                                    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (tt) async {
                                      if (_exRemainingSeconds > 1) {
                                        setState(() {
                                          _exRemainingSeconds -= 1;
                                        });
                                      } else {
                                        if (_exerciseIndex < _exerciseFlow.length - 1) {
                                          setState(() {
                                            _exerciseIndex += 1;
                                            _exRemainingSeconds = 5;
                                            _exAnimVersion += 1;
                                          });
                                        } else {
                                          tt.cancel();
                                          setState(() {
                                            _isExerciseRunning = false;
                                            _exerciseIndex = -1;
                                          });
                                          try {
                                            await WorksheetService(FirebaseFirestore.instance, FirebaseAuth.instance).saveEntry(
                                              worksheetId: 'exercise',
                                              data: {
                                                'flow': _exerciseFlow.map((e) => e['label']).toList(),
                                                'durationPerStepSec': 5,
                                                'date': DateTime.now().toIso8601String(),
                                              },
                                            );
                                          } catch (_) {}
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exercise flow completed')));
                                        }
                                      }
                                    });
                                  }
                                });
                              },
                              child: const Text('Start Exercise'),
                            ),
                          ),
                        if (_isExerciseRunning)
                          Expanded(
                            child: Center(
                              child: _countdown > 0
                                  ? Text(
                                      _countdown.toString(),
                                      style: Theme.of(context).textTheme.displayLarge,
                                    )
                                      .animate(target: _countdown.toDouble())
                                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 300.ms)
                                      .then()
                                      .fadeIn(duration: 300.ms)
                                  : Container(
                                      key: ValueKey('ex_${_exerciseIndex}_$_exAnimVersion'),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(_exerciseFlow[_exerciseIndex]['icon'] as IconData, color: AppColors.primary, size: 28),
                                              const SizedBox(width: 10),
                                              Text(
                                                _exerciseFlow[_exerciseIndex]['label'] as String,
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: 220,
                                            child: LinearProgressIndicator(
                                              value: _exRemainingSeconds / 5,
                                              minHeight: 6,
                                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                      .animate(target: _exAnimVersion.toDouble())
                                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.08, 1.08), duration: 220.ms)
                                      .then()
                                      .scale(begin: const Offset(1.08, 1.08), end: const Offset(1.0, 1.0), duration: 240.ms),
                            ),
                          ),
                        if (_isExerciseRunning)
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                _exerciseTimer?.cancel();
                                setState(() {
                                  _isExerciseRunning = false;
                                  _exerciseIndex = -1;
                                  _countdown = 0;
                                });
                              },
                              child: const Text('Stop'),
                            ),
                          ),
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

 

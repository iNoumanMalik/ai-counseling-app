import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import 'dart:async';

final _breathingStateProvider = StateProvider<String>((ref) => 'ready');
final _sessionDurationProvider = StateProvider<int>((ref) => 60);
final _remainingTimeProvider = StateProvider<int>((ref) => 60);

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen> {
  Timer? _timer;
  final int _cycleDuration = 6; // seconds for one breath cycle
  int _currentCycleStep = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isRunning = true;
    });
    ref.read(_breathingStateProvider.notifier).state = 'inhale';

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentCycleStep++;
        final remaining = ref.read(_remainingTimeProvider);
        
        if (remaining <= 0) {
          _stopBreathing();
          return;
        }

        ref.read(_remainingTimeProvider.notifier).state = remaining - 1;

        // Breathing cycle: 3s inhale, 3s exhale
        if (_currentCycleStep <= 3) {
          ref.read(_breathingStateProvider.notifier).state = 'inhale';
        } else if (_currentCycleStep <= 6) {
          ref.read(_breathingStateProvider.notifier).state = 'exhale';
        }

        if (_currentCycleStep >= _cycleDuration) {
          _currentCycleStep = 0;
        }
      });
    });
  }

  void _stopBreathing() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentCycleStep = 0;
    });
    ref.read(_breathingStateProvider.notifier).state = 'ready';
    ref.read(_remainingTimeProvider.notifier).state =
        ref.read(_sessionDurationProvider);
  }

  void _setDuration(int seconds) {
    ref.read(_sessionDurationProvider.notifier).state = seconds;
    ref.read(_remainingTimeProvider.notifier).state = seconds;
  }

  @override
  Widget build(BuildContext context) {
    final breathingState = ref.watch(_breathingStateProvider);
    final remaining = ref.watch(_remainingTimeProvider);
    final duration = ref.watch(_sessionDurationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.breathingTitle),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Breathing circle
                      _BreathingCircle(state: breathingState, isRunning: _isRunning)
                          .animate(target: _isRunning ? 1 : 0)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: const Duration(seconds: 3),
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.2, 1.2),
                            end: const Offset(0.8, 0.8),
                            duration: const Duration(seconds: 3),
                          ),
                      const SizedBox(height: 48),

                      // Breathing instruction
                      Text(
                        breathingState == 'inhale'
                            ? AppStrings.breathingInhale
                            : breathingState == 'exhale'
                                ? AppStrings.breathingExhale
                                : 'Ready to breathe?',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      )
                          .animate(target: _isRunning ? 1 : 0)
                          .fadeIn(duration: 300.ms)
                          .scale(),
                      const SizedBox(height: 16),

                      // Timer
                      if (_isRunning)
                        Text(
                          '${remaining}s remaining',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.mediumGray,
                              ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms),
                    ],
                  ),
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Duration selector
                    if (!_isRunning) ...[
                      Text(
                        '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      // Wrap(
                      //   spacing: 12,
                      //   runSpacing: 12,
                      //   alignment: WrapAlignment.center,
                      //   children: [
                      //     _DurationButton(
                      //       label: AppStrings.breathingSession1Min,
                      //       seconds: 60,
                      //       isSelected: duration == 60,
                      //       onTap: () => _setDuration(60),
                      //     ),
                      //     _DurationButton(
                      //       label: AppStrings.breathingSession3Min,
                      //       seconds: 180,
                      //       isSelected: duration == 180,
                      //       onTap: () => _setDuration(180),
                      //     ),
                      //     _DurationButton(
                      //       label: AppStrings.breathingSession5Min,
                      //       seconds: 300,
                      //       isSelected: duration == 300,
                      //       onTap: () => _setDuration(300),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 32),
                    ],

                    // Start/Stop button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isRunning ? _stopBreathing : _startBreathing,
                        icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                        label: Text(_isRunning ? 'Stop' : 'Start'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingCircle extends StatelessWidget {
  final String state;
  final bool isRunning;

  const _BreathingCircle({
    required this.state,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final size = isRunning
        ? (state == 'inhale' ? 250.0 : 150.0)
        : 200.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: state == 'inhale' ? 0.6 : 0.3),
            AppColors.secondary.withValues(alpha: state == 'exhale' ? 0.4 : 0.2),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        scale: isRunning ? (state == 'inhale' ? 1.05 : 0.95) : 1,
        child: Center(
          child: Icon(
            Icons.water_drop_outlined,
            size: size * 0.4,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final String label;
  final int seconds;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationButton({
    required this.label,
    required this.seconds,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mediumGray,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.white : AppColors.darkText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    )
        .animate(target: isSelected ? 1 : 0)
        .scale(duration: 200.ms);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  // TODO: Replace with actual audio file paths
  final List<MeditationTrack> _tracks = const [
    MeditationTrack(
      id: '1',
      title: 'Calm Breathing',
      duration: '5:00',
      // asset: 'assets/audio/calm_breathing.mp3',
    ),
    MeditationTrack(
      id: '2',
      title: 'Forest Sounds',
      duration: '10:00',
      // asset: 'assets/audio/forest_sounds.mp3',
    ),
    MeditationTrack(
      id: '3',
      title: 'Ocean Waves',
      duration: '15:00',
      // asset: 'assets/audio/ocean_waves.mp3',
    ),
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack(MeditationTrack track) async {
    // TODO: Uncomment when audio files are added
    // setState(() {
    //   _isLoading = true;
    // });
    // await _audioPlayer.play(AssetSource(track.asset));
    // setState(() {
    //   _isPlaying = true;
    //   _isLoading = false;
    // });
    
    // Placeholder message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio file placeholder: ${track.title}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _stopTrack() {
    _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeMeditation),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Meditation Library',
                style: Theme.of(context).textTheme.displaySmall,
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Find your inner peace',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mediumGray,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 32),

              // Meditation tracks
              ..._tracks.map((track) {
                final index = _tracks.indexOf(track);
                return _MeditationTrackCard(
                  track: track,
                  isPlaying: _isPlaying,
                  isLoading: _isLoading,
                  onPlay: () => _playTrack(track),
                  onStop: _stopTrack,
                )
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2, end: 0);
              }),

              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Note',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Audio files need to be added to assets/audio/. '
                      'Replace placeholder tracks with actual meditation audio files.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeditationTrackCard extends StatelessWidget {
  final MeditationTrack track;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  const _MeditationTrackCard({
    required this.track,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlay,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.self_improvement_outlined,
                color: AppColors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                onPressed: isPlaying ? onStop : onPlay,
                color: AppColors.primary,
              ),
          ],
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

class MeditationTrack {
  final String id;
  final String title;
  final String duration;
  // final String asset;

  const MeditationTrack({
    required this.id,
    required this.title,
    required this.duration,
    // required this.asset,
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/meditation_service.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/widgets/counseling_floating_button.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  MeditationTrack? _currentTrack;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final List<MeditationTrack> _tracks = const [
    MeditationTrack(
      id: '1',
      title: 'Calm Breathing',
      duration: '5:00',
      asset: 'audio/audio1.mp3',
    ),
    MeditationTrack(
      id: '2',
      title: 'Forest Sounds',
      duration: '10:00',
      asset: 'audio/audio2.mp3',
    ),
    MeditationTrack(
      id: '3',
      title: 'Ocean Waves',
      duration: '15:00',
      asset: 'audio/audio3.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) async {
      if (mounted) {
        // Capture trackId before clearing state
        final trackId = _currentTrack?.id;
        setState(() {
          _isPlaying = false;
          _currentTrack = null;
          _currentPosition = Duration.zero;
        });
        // Mark completed in Firestore when a track finishes
        try {
          if (trackId != null) {
            await MeditationService(FirebaseFirestore.instance, FirebaseAuth.instance)
                .markCompleted(trackId, true);
            final badges = await StorageService.getBadges();
            if (!badges.contains('meditation_first')) {
              await StorageService.addBadge('meditation_first');
            }
          }
        } catch (_) {}
      }
    });
  }

  Future<void> _playTrack(MeditationTrack track) async {
    try {
      setState(() {
        _currentTrack = track;
      });

      // Stop any currently playing audio
      await _audioPlayer.stop();

      // Play the new track
      await _audioPlayer.play(AssetSource(track.asset));
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _currentTrack = null;
      });
    }
  }

  Future<void> _pauseTrack() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _resumeTrack() async {
    await _audioPlayer.resume();
    setState(() {
      _isPlaying = true;
    });
  }

  void _stopTrack() async {
    await _audioPlayer.stop();
    if (mounted) {
      // Capture trackId before clearing state
      final trackId = _currentTrack?.id;
      setState(() {
        _isPlaying = false;
        _currentTrack = null;
        _currentPosition = Duration.zero;
      });
      // Consider stop as completion for short practices
      if (trackId != null) {
        await MeditationService(FirebaseFirestore.instance, FirebaseAuth.instance)
            .markCompleted(trackId, true);
        try {
          final badges = await StorageService.getBadges();
          if (!badges.contains('meditation_first')) {
            await StorageService.addBadge('meditation_first');
          }
        } catch (_) {}
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeMeditation),
        actions: [
          if (_isPlaying && _currentTrack != null)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopTrack,
              tooltip: 'Stop',
            ),
        ],
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Now Playing Section
              if (_currentTrack != null && _isPlaying) 
                _NowPlayingSection(
                  track: _currentTrack!,
                  currentPosition: _currentPosition,
                  totalDuration: _totalDuration,
                  onPause: _pauseTrack,
                  onStop: _stopTrack,
                  formatDuration: _formatDuration,
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.5, end: 0),

              Expanded(
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
                            color: AppColors.dark700,
                          ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 32),

                    // Meditation tracks
                    ..._tracks.map((track) {
                      final index = _tracks.indexOf(track);
                      final isCurrentTrack = _currentTrack?.id == track.id;
                      
                      return _MeditationTrackCard(
                        track: track,
                        isPlaying: _isPlaying && isCurrentTrack,
                        isCurrentTrack: isCurrentTrack,
                        onPlay: () => _playTrack(track),
                        onPause: _pauseTrack,
                        onResume: _resumeTrack,
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
                            color: AppColors.primary.withValues(alpha: 0.1),
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
                              Icon(Icons.volume_up, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Audio Tips',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                      Text(
                        'Find a quiet space, use headphones for better experience, '
                        'and focus on your breathing during meditation.',
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
        ],
      ),
    ))),
        const CounselingFloatingButton(),
      ],
    );
  }
}

class _MeditationTrackCard extends StatelessWidget {
  final MeditationTrack track;
  final bool isPlaying;
  final bool isCurrentTrack;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const _MeditationTrackCard({
    required this.track,
    required this.isPlaying,
    required this.isCurrentTrack,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isCurrentTrack ? AppColors.primary.withOpacity(0.1) : AppColors.white,
      elevation: isCurrentTrack ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isCurrentTrack ? AppColors.secondaryGradient : AppColors.primaryGradient,
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
                          color: isCurrentTrack ? AppColors.primary : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCurrentTrack ? AppColors.primary : AppColors.mediumGray,
                        ),
                  ),
                ],
              ),
            ),
            if (isPlaying)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.pause, color: AppColors.primary),
                    onPressed: onPause,
                    tooltip: 'Pause',
                  ),
                  IconButton(
                    icon: Icon(Icons.stop, color: AppColors.secondary),
                    onPressed: onStop,
                    tooltip: 'Stop',
                  ),
                ],
              )
            else if (isCurrentTrack)
              IconButton(
                icon: Icon(Icons.play_arrow, color: AppColors.primary),
                onPressed: onResume,
                tooltip: 'Resume',
              )
            else
              IconButton(
                icon: Icon(Icons.play_arrow, color: AppColors.primary),
                onPressed: onPlay,
                tooltip: 'Play',
              ),
          ],
        ),
      ),
    ).animate()
    .fadeIn(duration: 300.ms)
    .scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 300.ms,
    );
  }
}

class _NowPlayingSection extends StatelessWidget {
  final MeditationTrack track;
  final Duration currentPosition;
  final Duration totalDuration;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final String Function(Duration) formatDuration;

  const _NowPlayingSection({
    required this.track,
    required this.currentPosition,
    required this.totalDuration,
    required this.onPause,
    required this.onStop,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalDuration.inSeconds > 0 
        ? currentPosition.inSeconds / totalDuration.inSeconds 
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Now Playing',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.self_improvement_outlined,
                  color: AppColors.white,
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
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      track.duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.pause, color: AppColors.white),
                    onPressed: onPause,
                    tooltip: 'Pause',
                  ),
                  IconButton(
                    icon: Icon(Icons.stop, color: AppColors.white),
                    onPressed: onStop,
                    tooltip: 'Stop',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(currentPosition),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                  ),
                  Text(
                    formatDuration(totalDuration),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MeditationTrack {
  final String id;
  final String title;
  final String duration;
  final String asset;

  const MeditationTrack({
    required this.id,
    required this.title,
    required this.duration,
    required this.asset,
  });
}

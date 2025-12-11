import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import '../../../core/widgets/counseling_floating_button.dart';
import '../../../core/utils/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/user_service.dart';
import '../../../services/mood_service.dart';
import '../widgets/mood_selector.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;
  String? _lastMood;
  int? _lastIntensity;
  List<String> _lastTags = const [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final data = await UserService(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      ).getUserData();
      setState(() {
        _userName = (data?['name'] as String?) ?? 'Friend';
        _lastMood = (data?['lastMood'] as String?) ?? _lastMood;
      });
      try {
        final history = await ref.read(moodServiceProvider).getMoodHistory();
        if (history.isNotEmpty) {
          final latest = history.first;
          setState(() {
            _lastIntensity = latest['intensity'] as int?;
            _lastTags = (latest['tags'] as List?)?.map((e)=>e.toString()).toList() ?? const [];
          });
        }
      } catch (_) {
        final local = await StorageService.getMoodHistory();
        if (local.isNotEmpty) {
          final latest = local.first;
          setState(() {
            _lastIntensity = latest['intensity'] as int?;
            _lastTags = (latest['tags'] as List?)?.map((e)=>e.toString()).toList() ?? const [];
          });
        }
      }
    } catch (_) {
      final local = await StorageService.getUserName();
      setState(() {
        _userName = local ?? 'Friend';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: AnimatedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Greeting
                          Text(
                            AppStrings.homeGreeting.replaceAll(
                              '{name}',
                              _userName ?? 'Friend',
                            ),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 24),

                          // Combined Personalized Card
                          if (_lastMood != null)
                            _PersonalizedInsightsCard(
                              mood: _lastMood!,
                              intensity: _lastIntensity,
                              tags: _lastTags,
                              onNavigate: (route) => context.push(route),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 24),

                          // Mood selector
                          Text(
                            AppStrings.homeMoodSelection,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                          const SizedBox(height: 16),
                          const MoodSelector()
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 32),

                          // Quick actions
                          Text(
                            AppStrings.homeQuickActions,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                          const SizedBox(height: 16),

                          // Quick action cards
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: [
                              QuickActionCard(
                                title: AppStrings.homeBreathingExercise,
                                icon: Icons.air_outlined,
                                gradient: AppColors.primaryGradient,
                                onTap: () => context.push('/breathing'),
                              ),
                              QuickActionCard(
                                title: AppStrings.homeJournal,
                                icon: Icons.edit_note_outlined,
                                gradient: AppColors.secondaryGradient,
                                onTap: () => context.push('/journal'),
                              ),
                              QuickActionCard(
                                title: AppStrings.homeMeditation,
                                icon: Icons.self_improvement_outlined,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accent.withOpacity(0.7),
                                  ],
                                ),
                                onTap: () => context.push('/meditation'),
                              ),
                              QuickActionCard(
                                title: 'Worksheets',
                                icon: Icons.menu_book_outlined,
                                gradient: AppColors.secondaryGradient,
                                onTap: () => context.push('/worksheets'),
                              ),
                              QuickActionCard(
                                title: AppStrings.homeExploreCounselors,
                                icon: Icons.people_outline,
                                gradient: AppColors.primaryGradient,
                                onTap: () => context.push('/discovery'),
                              ),
                              QuickActionCard(
                                title: 'MCQ Check-in',
                                icon: Icons.quiz_outlined,
                                gradient: AppColors.secondaryGradient,
                                onTap: () => context.push('/checkin'),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 32),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AnimatedBottomNav(currentIndex: 0),
        ),
        const CounselingFloatingButton(),
      ],
    );
  }
}

class _PersonalizedInsightsCard extends StatelessWidget {
  final String mood;
  final int? intensity;
  final List<String> tags;
  final void Function(String) onNavigate;

  const _PersonalizedInsightsCard({
    required this.mood,
    required this.intensity,
    required this.tags,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isHighIntensity = intensity != null && intensity! >= 4;
    final isAnxiousOrSad = mood == AppStrings.moodAnxious || mood == AppStrings.moodSad;
    final isOkay = mood == AppStrings.moodOkay;
    
    // Get the appropriate gradient based on mood
    final gradient = _getMoodGradient(mood, isHighIntensity);
    
    // Determine content
    final suggestion = _getSuggestion(mood, isHighIntensity, isOkay);
    final planItems = _getPlanItems(mood, isHighIntensity, tags);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.psychology_outlined,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMoodIcon(mood),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            mood.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PERSONALIZED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Main suggestion
                Text(
                  suggestion.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  suggestion.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                
                const SizedBox(height: 20),
                
                // Today's plan section
                Row(
                  children: [
                    Icon(
                      Icons.today_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "TODAY'S PLAN",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: planItems.map((item) => _buildPlanButton(item, context)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanButton(_PlanItem item, BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onNavigate(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getMoodGradient(String mood, bool isHighIntensity) {
    if (mood == AppStrings.moodAnxious || isHighIntensity) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ],
      );
    } else if (mood == AppStrings.moodSad) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
        ],
      );
    } else if (mood == AppStrings.moodOkay) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4facfe),
          const Color(0xFF00f2fe),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
        ],
      );
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case AppStrings.moodHappy:
        return Icons.emoji_emotions_outlined;
      case AppStrings.moodSad:
        return Icons.sentiment_dissatisfied_outlined;
      case AppStrings.moodAnxious:
        return Icons.psychology_outlined;
      case AppStrings.moodOkay:
        return Icons.sentiment_neutral_outlined;
      default:
        return Icons.mood_outlined;
    }
  }

  _Suggestion _getSuggestion(String mood, bool isHighIntensity, bool isOkay) {
    if (mood == AppStrings.moodAnxious || mood == AppStrings.moodSad || isHighIntensity) {
      return _Suggestion(
        'Take a moment for yourself',
        'Based on your recent mood, try a short breathing exercise or meditation to center yourself.',
      );
    } else if (isOkay) {
      return _Suggestion(
        'Build positive momentum',
        'Maintain your balance with a quick journal entry to reflect on today.',
      );
    } else {
      return _Suggestion(
        'Deepen your self-awareness',
        'Explore a worksheet to gain insights and continue your growth journey.',
      );
    }
  }

  List<_PlanItem> _getPlanItems(String mood, bool isHighIntensity, List<String> tags) {
    final List<_PlanItem> items = [];
    
    if (mood == AppStrings.moodAnxious || mood == AppStrings.moodSad || isHighIntensity) {
      items.add(_PlanItem('3-min Breathing', Icons.air_outlined, '/breathing'));
      items.add(_PlanItem('5-min Meditation', Icons.self_improvement_outlined, '/meditation'));
    } else {
      items.add(_PlanItem('Journal Prompt', Icons.edit_note_outlined, '/journal'));
      items.add(_PlanItem('CBT Worksheet', Icons.menu_book_outlined, '/worksheets'));
    }
    
    if (tags.contains('sleep')) {
      items.add(_PlanItem('Wind-down', Icons.nightlight_round_outlined, '/breathing'));
    }
    
    // Always include at least 2 items
    if (items.length < 2) {
      items.add(_PlanItem('Quick Check-in', Icons.quiz_outlined, '/checkin'));
    }
    
    return items;
  }
}

class _Suggestion {
  final String title;
  final String description;
  
  _Suggestion(this.title, this.description);
}

class _PlanItem {
  final String title;
  final IconData icon;
  final String route;
  
  _PlanItem(this.title, this.icon, this.route);
}
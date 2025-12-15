import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:semester_project/config/colors.dart';
import 'package:semester_project/core/widgets/animated_background.dart';

class MentalHealthSupportScreen extends StatefulWidget {
  const MentalHealthSupportScreen({super.key});

  @override
  State<MentalHealthSupportScreen> createState() => _MentalHealthSupportScreenState();
}

class _MentalHealthSupportScreenState extends State<MentalHealthSupportScreen> {
  int currentMythFactIndex = 0;

  final List<Map<String, dynamic>> mythFacts = [
    {
      'isMyth': true,
      'text': '"Mental health issues are rare"',
      'detail': '1 in 5 adults experience mental illness each year',
    },
    {
      'isMyth': false,
      'text': '"Therapy is for everyone"',
      'detail': 'Therapy can benefit anyone, not just those in crisis',
    },
    {
      'isMyth': true,
      'text': '"You can just snap out of it"',
      'detail': 'Mental health conditions require proper care and treatment',
    },
    {
      'isMyth': false,
      'text': '"Medication is the only treatment"',
      'detail': 'Many effective treatments exist including therapy and lifestyle changes',
    },
    {
      'isMyth': true,
      'text': '"Children don\'t experience mental health issues"',
      'detail': 'Mental health conditions can affect people of all ages',
    },
  ];

  void nextMythFact() {
    setState(() {
      currentMythFactIndex = (currentMythFactIndex + 1) % mythFacts.length;
    });
  }

  void previousMythFact() {
    setState(() {
      currentMythFactIndex = (currentMythFactIndex - 1 + mythFacts.length) % mythFacts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mental Wellness Hub',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Educational Content
                _buildSectionTitle('Learn & Understand', Icons.school),
                const SizedBox(height: 16),
                _buildEducationCards(context),
                const SizedBox(height: 32),
                
                // Myth vs Fact
                _buildSectionTitle('Myth vs Fact', Icons.lightbulb),
                const SizedBox(height: 16),
                _buildInteractiveMythFact(),
                const SizedBox(height: 32),
                
                // Crisis Resources
                _buildCrisisSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.dark900,
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCards(BuildContext context) {
    final articles = [
      EducationCard(
        title: 'Understanding Anxiety',
        description: 'Learn about common signs, symptoms, and coping strategies',
        icon: Icons.psychology_outlined,
        time: '5 min read',
        route: '/articles/anxiety',
      ),
      EducationCard(
        title: 'Stress & Your Body',
        description: 'How stress affects physical and mental health',
        icon: Icons.favorite_border,
        time: '4 min read',
        route: '/articles/stress',
      ),
      EducationCard(
        title: 'When to Seek Help',
        description: 'Recognizing signs that professional support may be beneficial',
        icon: Icons.medical_services_outlined,
        time: '3 min read',
        route: '/articles/help',
      ),
      EducationCard(
        title: 'Mindfulness Basics',
        description: 'Simple techniques to stay present and grounded',
        icon: Icons.self_improvement_outlined,
        time: '6 min read',
        route: '/articles/mindfulness',
      ),
    ];

    return Column(
      children: articles.map((article) {
        final index = articles.indexOf(article);
        return _buildEducationCard(context, article, index);
      }).toList(),
    );
  }

  Widget _buildEducationCard(BuildContext context, EducationCard article, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.lightGray300.withOpacity(0.3)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () => context.push(article.route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  article.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.dark900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkText.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.darkText.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkText.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.lightGray300,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0),
    );
  }

  Widget _buildInteractiveMythFact() {
    final currentItem = mythFacts[currentMythFactIndex];
    final isMyth = currentItem['isMyth'] as bool;
    final text = currentItem['text'] as String;
    final detail = currentItem['detail'] as String;

    return Column(
      children: [
        // Current Myth/Fact Card
        AnimatedSwitcher(
          duration: 300.ms,
          child: Container(
            key: ValueKey<int>(currentMythFactIndex),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isMyth ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isMyth ? Colors.red.shade100 : Colors.green.shade100,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMyth ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isMyth ? 'MYTH' : 'FACT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.dark900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkText.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Navigation Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            IconButton(
              onPressed: previousMythFact,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${currentMythFactIndex + 1} / ${mythFacts.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark900,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Next Button
            IconButton(
              onPressed: nextMythFact,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            mythFacts.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentMythFactIndex
                    ? AppColors.primary
                    : AppColors.lightGray300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrisisSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.emergency_outlined,
                color: Colors.red.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Crisis Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'If you\'re in immediate crisis or having thoughts of harming yourself, please reach out for help now.',
            style: TextStyle(
              color: AppColors.dark900,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCrisisButton(
                context,
                'National Suicide Prevention',
                '988',
                Colors.red.shade700,
              ),
              _buildCrisisButton(
                context,
                'Edhi Ambulance Service',
                'Dial 115',
                Colors.orange.shade700,
              ),
              _buildCrisisButton(
                context,
                'Emergency Services',
                '911',
                Colors.red.shade900,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildCrisisButton(
    BuildContext context,
    String title,
    String number,
    Color color,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EducationCard {
  final String title;
  final String description;
  final IconData icon;
  final String time;
  final String route;

  EducationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.time,
    required this.route,
  });
}
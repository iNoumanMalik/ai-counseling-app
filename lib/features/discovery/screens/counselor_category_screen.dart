import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/colors.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../data/dummy/counselors_data.dart';
import '../widgets/counselor_card.dart';
import '../../../core/widgets/webview_modal.dart';

class CounselorCategoryScreen extends StatelessWidget {
  final String category;

  const CounselorCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final counselors = CounselorsData.getCounselorsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Marham',
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const WebViewModal(
                  url: 'https://www.marham.pk/doctors/psychologist',
                  title: 'Marham',
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBackground(
        child: counselors.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_outlined,
                      size: 80,
                      color: AppColors.mediumGray,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No counselors found in this category',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: counselors.length,
                itemBuilder: (context, index) {
                  final counselor = counselors[index];
                  return CounselorCard(
                    counselor: counselor,
                    onTap: () {
                      context.push('/discovery/counselor/${counselor.id}');
                    },
                  )
                      .animate(delay: (index * 50).ms)
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0);
                },
              ),
      ),
    );
  }
}


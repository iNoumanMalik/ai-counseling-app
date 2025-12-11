import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/strings.dart';
import '../../../core/widgets/animated_background.dart';
import '../../../core/widgets/animated_bottom_nav.dart';
import '../../../data/dummy/counselors_data.dart';
import '../widgets/category_card.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = CounselorsData.categories;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      AppStrings.discoveryTitle,
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.2, end: 0),
                  ],
                ),
              ),

              // Categories
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text(
                      AppStrings.discoveryCategories,
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Category grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CategoryCard(
                          category: category,
                          onTap: () {
                            _launchUrl('https://www.marham.pk/doctors/psychologist');
                          },
                        )
                            .animate(delay: (index * 50).ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2, end: 0);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AnimatedBottomNav(currentIndex: 1),
    );
  }
}